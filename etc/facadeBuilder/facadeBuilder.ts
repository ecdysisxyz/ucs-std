import { parse } from '@solidity-parser/parser';
import * as fs from 'fs-extra';
import * as path from 'path';
import * as yaml from 'js-yaml';

// Load facade configuration
interface FacadeConfig {
    bundleName: string;
    bundleDirName: string;
    facades: FacadeDefinition[];
}

interface FacadeDefinition {
    name: string;
    excludeFileNames: string[];
    excludeFunctionNames: string[];
}

interface FacadeObjects {
    files: FileSignature[],
    errors: ErrorSignature[],
    events: EventSignature[],
    functions: FunctionSignature[],
}

interface FileSignature {
    name: string;
    origin: string; // Name of the origin file
}
interface ErrorSignature {
    name: string;
    parameters: string;
    origin: string; // Name of the origin file
    imported: boolean;
}
interface EventSignature {
    name: string;
    parameters: string;
    origin: string; // Name of the origin file
    imported: boolean;
}
interface FunctionSignature {
    name: string;
    visibility: string;
    stateMutability: string;
    parameters: string;
    returnParameters: string;
    origin: string; // Name of the origin file
}

// 新しいクラスを作成
class FacadeBuilder {
    private facadeConfigPath: string;
    private facadeDir: string;
    private projectRoot: string;

    constructor(facadeConfigPath: string, facadeDir: string, projectRoot: string) {
        this.facadeConfigPath = facadeConfigPath;
        this.facadeDir = facadeDir;
        this.projectRoot = projectRoot;
    }

    async build() {
        process.chdir(this.projectRoot);
        await fs.ensureDir(path.resolve(this.facadeDir));

        const facadeConfigs = await this.loadConfigurations();
        const facadeFiles = await getSolidityFiles(this.facadeDir);

        for (const config of facadeConfigs) {
            await this.processBuilderConfig(config, facadeFiles);
        }
    }

    private async loadConfigurations(): Promise<FacadeConfig[]> {
        try {
            const configContent = await fs.readFile(this.facadeConfigPath, 'utf8');
            const configRaws = yaml.load(configContent) as any;

            for (let configRaw of configRaws) {
                if (!configRaw.bundleDirName) {
                    configRaw.bundleDirName = configRaw.bundleName
                }
                // Ensure excludeFileNames and excludeFunctionNames are arrays
                for (const facade of configRaw.facades) {
                    if (!facade.excludeFileNames) {
                        facade.excludeFileNames = [];
                    }
                    if (!facade.excludeFunctionNames) {
                        facade.excludeFunctionNames = [];
                    }
                }
            }

            const config = configRaws as FacadeConfig[];
            return config;
        } catch (err) {
            console.error(`Could not load facade configuration from ${this.facadeConfigPath}.`);
            process.exit(1);
        }
    }

    private async processBuilderConfig(
        config: FacadeConfig,
        existingFacadeFiles: string[]
    ) {
        validateFacadeConfig(config);

        const sourceFiles = await this.collectSourceFiles(config.bundleDirName);

        for (const facade of config.facades) {
            const facadeObject = await this.extractFacadeObjects(sourceFiles, facade);
            const generatedCode = await this.generateFacadeContract(
                facadeObject,
                facade,
                config,
            );
            const latestFacade = getLatestVersionFile(existingFacadeFiles, facade.name);
            if (latestFacade === null) {
                await this.writeFacadeContract(facade.name, [1, 0, 0], generatedCode);
                process.exit(1);
            }
            const latestObject: FacadeObjects = {
                files: [],
                errors: [],
                events: [],
                functions: []
            };
            try {
                const latestCode = await fs.readFile(latestFacade.file, 'utf8');
                const latestAst = parse(latestCode, { tolerant: true });

                // Extract functions from the AST
                traverseASTs(latestAst, latestObject, latestFacade.file, facade);
            } catch (err) {
                console.error(`Error parsing ${latestFacade.file}:`, err);
                process.exit(1);
            }
            const majorDiff = getSymmetricDifference(facadeObject.functions, latestObject.functions, ["name", "parameters"]);
            if (majorDiff.length > 0) {
                latestFacade.version[0]++;
            }
            const minorErrorDiff = getSymmetricDifference(facadeObject.errors, latestObject.errors, ["name", "parameters"]);
            const minorEventDiff = getSymmetricDifference(facadeObject.events, latestObject.events, ["name", "parameters"]);
            if (minorErrorDiff.length > 0 || minorEventDiff.length > 0) {
                latestFacade.version[1]++;
            }

            await this.writeFacadeContract(facade.name, latestFacade.version, generatedCode);
        }
    }

    private async collectSourceFiles(bundleDirName: string) {
        const functionDir = `./src/${bundleDirName}/functions`;
        const interfaceDir = `./src/${bundleDirName}/interfaces`;

        return {
            functionFiles: await getSolidityFiles(functionDir),
            interfaceFiles: await getSolidityFiles(interfaceDir)
        };
    }

    private async extractFacadeObjects(
        sourceFiles: { functionFiles: string[], interfaceFiles: string[] },
        facade: FacadeDefinition
    ): Promise<FacadeObjects> {
        const facadeObject: FacadeObjects = {
            files: [],
            errors: [],
            events: [],
            functions: []
        };
        const regex = /^(I)?.*(Errors|Events)\.sol$/;
        
        for (const file of sourceFiles.interfaceFiles) {
            const fileName = path.basename(file);

            if (!regex.test(fileName)) {
                continue;
            }

            facadeObject.files.push({ name: fileName.replace(/\.sol$/, ""), origin: file.replace(/\\/g, '/') });

            const content = await fs.readFile(file, 'utf8');
            try {
                const ast = parse(content, { tolerant: true });

                // Extract functions from the AST
                traverseASTs(ast, facadeObject, fileName, facade, true);
            } catch (err) {
                console.error(`Error parsing ${file}:`, err);
            }
        }

        for (const file of sourceFiles.functionFiles) {
            const fileName = path.basename(file);

            // Exclude files based on facade configuration
            if (facade.excludeFileNames.includes(fileName)) {
                continue;
            }

            const content = await fs.readFile(file, 'utf8');
            try {
                const ast = parse(content, { tolerant: true });

                // Extract functions from the AST
                traverseASTs(ast, facadeObject, fileName, facade);
            } catch (err) {
                console.error(`Error parsing ${file}:`, err);
            }
        }

        return facadeObject;
    }

    private async generateFacadeContract(
        objects: FacadeObjects,
        facade: FacadeDefinition,
        config: FacadeConfig
    ): Promise<string> {
        const facadeFilePath = path.join(this.facadeDir, `${facade.name}.sol`);
        let code = `// SPDX-License-Identifier: MIT
    pragma solidity ^0.8.24;
    
    import {Schema} from "src/${config.bundleDirName}/storage/Schema.sol";
    `;
    
        for (const file of objects.files) {
            code += `import {${file.name}} from "${file.origin}";\n`;
        }
    
        code += `\ncontract ${facade.name} is Schema, ${objects.files.map((file) => file.name).join(', ')} {\n`;
    
        for (const error of objects.errors) {
            if (error.imported) {
                continue;
            }
            code += generateError(error);
        }
        code += `\n`;
        for (const event of objects.events) {
            if (event.imported) {
                continue;
            }
            code += generateEvent(event);
        }
        code += `\n`;
        for (const func of objects.functions) {
            code += generateFunctionSignature(func);
        }
    
        code += `}\n`;
    
        return code;
    }

    private async writeFacadeContract(facadeName: string, version: number[], code: string) {
        // Write the facade contract to the output file
        const facadeFilePath = path.join(this.facadeDir, `${facadeName}V${version[0]}_${version[1]}_${version[2]}.sol`);
        await fs.writeFile(facadeFilePath, code);
        console.log(`Facade contract generated at ${facadeFilePath}`);
    }
}

// メイン関数を簡素化
async function main() {
    const facadeConfigPath = './facade.yaml';
    const facadeDir = './generated';
    const projectRoot = path.resolve(__dirname, '../../');

    const builder = new FacadeBuilder(facadeConfigPath, facadeDir, projectRoot);

    try {
        await builder.build();
    } catch (error) {
        console.error('Facade generation failed:', error);
        process.exit(1);
    }
}

// async function main1() {
//     const facadeDir = './generated';
//     const projectRoot = path.resolve(__dirname, '../../');
//     process.chdir(projectRoot);

//     // Ensure output directory exists
//     await fs.ensureDir(path.resolve(facadeDir));
//     const facadeFiles = await getSolidityFiles(facadeDir);

//     // Load facade configuration
//     const facadeConfigs: FacadeConfig[] = [];

//     for (const facadeConfig of facadeConfigs) {
//         validateFacadeConfig(facadeConfig);

//         const functionDir = `./src/${facadeConfig.bundleDirName}/functions`; // Adjust the path as needed
//         const interfaceDir = `./src/${facadeConfig.bundleDirName}/interfaces`; // Adjust the path as needed
//         // Recursively read all Solidity files in the source directory
//         const functionFiles = await getSolidityFiles(functionDir);
//         const interfaceFiles = await getSolidityFiles(interfaceDir);

//         const regex = /^(I)?.*(Errors|Events)\.sol$/;

//         // Process each facade
//         for (const facade of facadeConfig.facades) {
//             const facadeObject: FacadeObjects = {
//                 files: [],
//                 errors: [],
//                 events: [],
//                 functions: []
//             };

//             for (const file of interfaceFiles) {
//                 const fileName = path.basename(file);

//                 if (!regex.test(fileName)) {
//                     continue;
//                 }

//                 facadeObject.files.push({ name: fileName.replace(/\.sol$/, ""), origin: file.replace(/\\/g, '/') });

//                 const content = await fs.readFile(file, 'utf8');
//                 try {
//                     const ast = parse(content, { tolerant: true });

//                     // Extract functions from the AST
//                     traverseASTs(ast, facadeObject, fileName, facade, true);
//                 } catch (err) {
//                     console.error(`Error parsing ${file}:`, err);
//                 }
//             }

//             for (const file of functionFiles) {
//                 const fileName = path.basename(file);

//                 // Exclude files based on facade configuration
//                 if (facade.excludeFileNames.includes(fileName)) {
//                     continue;
//                 }

//                 const content = await fs.readFile(file, 'utf8');
//                 try {
//                     const ast = parse(content, { tolerant: true });

//                     // Extract functions from the AST
//                     traverseASTs(ast, facadeObject, fileName, facade);
//                 } catch (err) {
//                     console.error(`Error parsing ${file}:`, err);
//                 }
//             }

//             // Generate facade contract
//             const generatedCode = await generateFacadeContract(facadeObject, facade, facadeConfig);

//             const latestFacade = getLatestVersionFile(facadeFiles, facade.name);
//             if (latestFacade === null) {
//                 writeFacadeContract(facade.name, [1, 0, 0], generatedCode);
//                 process.exit(1);
//             }

//             const latestObject: FacadeObjects = {
//                 files: [],
//                 errors: [],
//                 events: [],
//                 functions: []
//             };
//             try {
//                 const generatedAst = parse(generatedCode, { tolerant: true });

//                 // Extract functions from the AST
//                 traverseASTs(generatedAst, latestObject, latestFacade.file, facade);
//             } catch (err) {
//                 console.error(`Error parsing ${latestFacade.file}:`, err);
//                 process.exit(1);
//             }
//             const majorDiff = getSymmetricDifference(facadeObject.functions, latestObject.functions, ["name", "parameters"]);
//             if (majorDiff.length > 0) {
//                 latestFacade.version[0]++;
//             }
//             let minorDiff = getSymmetricDifference(facadeObject.errors, latestObject.errors, ["name", "parameters"]);
//             if (minorDiff.length > 0) {
//                 latestFacade.version[1]++;
//             }
//             minorDiff = getSymmetricDifference(facadeObject.events, latestObject.events, ["name", "parameters"]);
//             if (minorDiff.length > 0) {
//                 latestFacade.version[1]++;
//             }
//             writeFacadeContract(facade.name, latestFacade.version, generatedCode);
//         }
//     }
// }

function validateFacadeConfig(facadeConfig: FacadeConfig) {
    // Ensure required fields are present
    if (!facadeConfig.bundleName || !facadeConfig.bundleDirName) {
        console.error('Error: bundleName and bundleDirName are required in facade.yaml');
        process.exit(1);
    }

    if (!facadeConfig.facades || facadeConfig.facades.length === 0) {
        console.error('Error: At least one facade must be defined in facade.yaml');
        process.exit(1);
    }

    for (const facade of facadeConfig.facades) {
        if (!facade.name) {
            console.error('Error: Each facade must have a name');
            process.exit(1);
        }
    }
}

async function getSolidityFiles(dir: string): Promise<string[]> {
    let files: string[] = [];
    const items = await fs.readdir(dir);

    for (const item of items) {
        const fullPath = path.join(dir, item);
        const stat = await fs.stat(fullPath);

        if (stat.isDirectory()) {
            const subFiles = await getSolidityFiles(fullPath);
            files = files.concat(subFiles);
        } else if (stat.isFile() && path.extname(item) === '.sol') {
            files.push(fullPath);
        }
    }

    return files;
}

function getLatestVersionFile(files: string[], baseName: string): { file: string; version: number[] } | null {
    const regex = new RegExp(`^${baseName}(?:V(\\d+)_(\\d+)_(\\d+))?\\.sol$`);

    return files
        .map(file => {
            const match = path.basename(file).match(regex);
            if (match) {
                const [_, major, minor, patch] = match.map(Number);
                return {
                    file,
                    version: [major || 1, minor || 0, patch || 0],
                };
            }
            return null;
        })
        .filter((item): item is { file: string; version: number[] } => item !== null)
        .sort((a, b) => {
            // バージョン配列を比較 (降順)
            for (let i = 0; i < 3; i++) {
                if (b.version[i] !== a.version[i]) {
                    return b.version[i] - a.version[i];
                }
            }
            return 0;
        })[0] || null;
}

function getSymmetricDifference<T>(
    array1: T[],
    array2: T[],
    keys: (keyof T)[]
): T[] {
    const isMatch = (a: T, b: T) => keys.every(key => a[key] === b[key]);

    // A ∪ B
    const union = [...array1, ...array2];
    // A ∩ B
    const intersection = array1.filter(item1 =>
        array2.some(item2 => isMatch(item1, item2))
    );

    // A ∪ B - A ∩ B
    return union.filter(item =>
        !intersection.some(intersectItem => isMatch(item, intersectItem))
    );
}

function traverseASTs(
    ast: any,
    facadeObjects: FacadeObjects,
    origin: string,
    facade: FacadeDefinition,
    imported: boolean = false
) {
    if (ast.type === 'FunctionDefinition' && ast.isConstructor === false) {
        extractFunctions(ast, facadeObjects.functions, origin, facade);
    } else if (ast.type === 'ContractDefinition') {
        // Traverse contract sub-nodes
        for (const subNode of ast.subNodes) {
            traverseASTs(subNode, facadeObjects, origin, facade, imported);
        }
    } else if (ast.type === 'SourceUnit') {
        // Traverse source unit nodes
        for (const child of ast.children) {
            traverseASTs(child, facadeObjects, origin, facade, imported);
        }
    } else if (ast.type === 'CustomErrorDefinition') {
        extractErrors(ast, facadeObjects.errors, origin, imported);
    } else if (ast.type === 'EventDefinition') {
        extractEvents(ast, facadeObjects.events, origin, imported);
    }
}

function extractErrors(
    ast: any,
    errors: ErrorSignature[],
    origin: string,
    imported: boolean
) {
    const error: ErrorSignature = {
        name: ast.name,
        parameters: ast.parameters
            .map((param: any) => getParameter(param))
            .join(', '),
        origin: origin,
        imported: imported
    };
    errors.push(error);
}

function extractEvents(
    ast: any,
    events: EventSignature[],
    origin: string,
    imported: boolean
) {
    const event: EventSignature = {
        name: ast.name,
        parameters: ast.parameters
            .map((param: any) => getParameter(param))
            .join(', '),
        origin: origin,
        imported: imported
    };
    events.push(event);
}

function extractFunctions(
    ast: any,
    functions: FunctionSignature[],
    origin: string,
    facade: FacadeDefinition
) {
    // Skip functions based on the criteria
    if (
        !ast.name || // Skip unnamed functions (constructor, fallback, receive)
        ast.name.startsWith('test') ||
        ast.name === 'setUp' ||
        ast.visibility === 'private' ||
        ast.visibility === 'internal' ||
        facade.excludeFunctionNames.includes(ast.name)
    ) {
        return;
    }

    const func: FunctionSignature = {
        name: ast.name,
        visibility: ast.visibility || 'default',
        stateMutability: ast.stateMutability || '',
        parameters: ast.parameters
            .map((param: any) => getParameter(param))
            .join(', '),
        returnParameters: ast.returnParameters
            ? ast.returnParameters
                .map((param: any) => getParameter(param))
                .join(', ')
            : '',
        origin: origin, // Set the origin to the file name
    };

    // Add to functions array
    functions.push(func);
}

function getParameter(param: any): string {
    const typeName = getTypeName(param.typeName);
    return `${typeName}${param.storageLocation ? ' ' + param.storageLocation : ''}${param.name ? ' ' + param.name : ''
        }`;
}

function getTypeName(typeName: any): string {
    if (!typeName) return '';
    if (typeName.type === 'ElementaryTypeName') {
        return typeName.name;
    } else if (typeName.type === 'UserDefinedTypeName') {
        return typeName.namePath;
    } else if (typeName.type === 'Mapping') {
        return `mapping(${getTypeName(typeName.keyType)} => ${getTypeName(
            typeName.valueType,
        )})`;
    } else if (typeName.type === 'ArrayTypeName') {
        return `${getTypeName(typeName.baseTypeName)}[]`;
    } else if (typeName.type === 'FunctionTypeName') {
        // Simplify function type names for parameters
        return 'function';
    } else {
        return 'unknown';
    }
}

function generateError(error: ErrorSignature) {
    return `    error ${error.name}(${error.parameters});\n`
}
function generateEvent(event: EventSignature) {
    return `    event ${event.name}(${event.parameters});\n`
}
function generateFunctionSignature(func: FunctionSignature): string {
    const visibility =
        func.visibility !== 'default' ? func.visibility : 'public';
    const stateMutability = func.stateMutability
        ? ' ' + func.stateMutability
        : '';
    const returns = func.returnParameters
        ? ` returns (${func.returnParameters})`
        : '';
    return `    function ${func.name}(${func.parameters}) ${visibility}${stateMutability}${returns} {}\n`;
}

main().catch((err) => {
    console.error('Error:', err);
});

