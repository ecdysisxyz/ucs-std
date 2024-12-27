"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g = Object.create((typeof Iterator === "function" ? Iterator : Object).prototype);
    return g.next = verb(0), g["throw"] = verb(1), g["return"] = verb(2), typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
var __spreadArray = (this && this.__spreadArray) || function (to, from, pack) {
    if (pack || arguments.length === 2) for (var i = 0, l = from.length, ar; i < l; i++) {
        if (ar || !(i in from)) {
            if (!ar) ar = Array.prototype.slice.call(from, 0, i);
            ar[i] = from[i];
        }
    }
    return to.concat(ar || Array.prototype.slice.call(from));
};
Object.defineProperty(exports, "__esModule", { value: true });
var parser_1 = require("@solidity-parser/parser");
var fs = require("fs-extra");
var path = require("path");
var yaml = require("js-yaml");
// 新しいクラスを作成
var FacadeBuilder = /** @class */ (function () {
    function FacadeBuilder(facadeConfigPath, facadeDir, projectRoot) {
        this.facadeConfigPath = facadeConfigPath;
        this.facadeDir = facadeDir;
        this.projectRoot = projectRoot;
    }
    FacadeBuilder.prototype.build = function () {
        return __awaiter(this, void 0, void 0, function () {
            var facadeConfigs, facadeFiles, _i, facadeConfigs_1, config;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        process.chdir(this.projectRoot);
                        return [4 /*yield*/, fs.ensureDir(path.resolve(this.facadeDir))];
                    case 1:
                        _a.sent();
                        return [4 /*yield*/, this.loadConfigurations()];
                    case 2:
                        facadeConfigs = _a.sent();
                        return [4 /*yield*/, getSolidityFiles(this.facadeDir)];
                    case 3:
                        facadeFiles = _a.sent();
                        _i = 0, facadeConfigs_1 = facadeConfigs;
                        _a.label = 4;
                    case 4:
                        if (!(_i < facadeConfigs_1.length)) return [3 /*break*/, 7];
                        config = facadeConfigs_1[_i];
                        return [4 /*yield*/, this.processBuilderConfig(config, facadeFiles)];
                    case 5:
                        _a.sent();
                        _a.label = 6;
                    case 6:
                        _i++;
                        return [3 /*break*/, 4];
                    case 7: return [2 /*return*/];
                }
            });
        });
    };
    FacadeBuilder.prototype.loadConfigurations = function () {
        return __awaiter(this, void 0, void 0, function () {
            var configContent, configRaws, _i, configRaws_1, configRaw, _a, _b, facade, config, err_1;
            return __generator(this, function (_c) {
                switch (_c.label) {
                    case 0:
                        _c.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, fs.readFile(this.facadeConfigPath, 'utf8')];
                    case 1:
                        configContent = _c.sent();
                        configRaws = yaml.load(configContent);
                        for (_i = 0, configRaws_1 = configRaws; _i < configRaws_1.length; _i++) {
                            configRaw = configRaws_1[_i];
                            if (!configRaw.bundleDirName) {
                                configRaw.bundleDirName = configRaw.bundleName;
                            }
                            // Ensure excludeFileNames and excludeFunctionNames are arrays
                            for (_a = 0, _b = configRaw.facades; _a < _b.length; _a++) {
                                facade = _b[_a];
                                if (!facade.excludeFileNames) {
                                    facade.excludeFileNames = [];
                                }
                                if (!facade.excludeFunctionNames) {
                                    facade.excludeFunctionNames = [];
                                }
                            }
                        }
                        config = configRaws;
                        return [2 /*return*/, config];
                    case 2:
                        err_1 = _c.sent();
                        console.error("Could not load facade configuration from ".concat(this.facadeConfigPath, "."));
                        process.exit(1);
                        return [3 /*break*/, 3];
                    case 3: return [2 /*return*/];
                }
            });
        });
    };
    FacadeBuilder.prototype.processBuilderConfig = function (config, existingFacadeFiles) {
        return __awaiter(this, void 0, void 0, function () {
            var sourceFiles, _i, _a, facade, facadeObject, generatedCode, latestFacade, latestObject, latestCode, latestAst, err_2, majorDiff, minorErrorDiff, minorEventDiff;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        validateFacadeConfig(config);
                        return [4 /*yield*/, this.collectSourceFiles(config.bundleDirName)];
                    case 1:
                        sourceFiles = _b.sent();
                        _i = 0, _a = config.facades;
                        _b.label = 2;
                    case 2:
                        if (!(_i < _a.length)) return [3 /*break*/, 13];
                        facade = _a[_i];
                        return [4 /*yield*/, this.extractFacadeObjects(sourceFiles, facade)];
                    case 3:
                        facadeObject = _b.sent();
                        return [4 /*yield*/, this.generateFacadeContract(facadeObject, facade, config)];
                    case 4:
                        generatedCode = _b.sent();
                        latestFacade = getLatestVersionFile(existingFacadeFiles, facade.name);
                        if (!(latestFacade === null)) return [3 /*break*/, 6];
                        return [4 /*yield*/, this.writeFacadeContract(facade.name, [1, 0, 0], generatedCode)];
                    case 5:
                        _b.sent();
                        process.exit(1);
                        _b.label = 6;
                    case 6:
                        latestObject = {
                            files: [],
                            errors: [],
                            events: [],
                            functions: []
                        };
                        _b.label = 7;
                    case 7:
                        _b.trys.push([7, 9, , 10]);
                        return [4 /*yield*/, fs.readFile(latestFacade.file, 'utf8')];
                    case 8:
                        latestCode = _b.sent();
                        latestAst = (0, parser_1.parse)(latestCode, { tolerant: true });
                        // Extract functions from the AST
                        traverseASTs(latestAst, latestObject, latestFacade.file, facade);
                        return [3 /*break*/, 10];
                    case 9:
                        err_2 = _b.sent();
                        console.error("Error parsing ".concat(latestFacade.file, ":"), err_2);
                        process.exit(1);
                        return [3 /*break*/, 10];
                    case 10:
                        majorDiff = getSymmetricDifference(facadeObject.functions, latestObject.functions, ["name", "parameters"]);
                        if (majorDiff.length > 0) {
                            latestFacade.version[0]++;
                        }
                        minorErrorDiff = getSymmetricDifference(facadeObject.errors, latestObject.errors, ["name", "parameters"]);
                        minorEventDiff = getSymmetricDifference(facadeObject.events, latestObject.events, ["name", "parameters"]);
                        if (minorErrorDiff.length > 0 || minorEventDiff.length > 0) {
                            latestFacade.version[1]++;
                        }
                        return [4 /*yield*/, this.writeFacadeContract(facade.name, latestFacade.version, generatedCode)];
                    case 11:
                        _b.sent();
                        _b.label = 12;
                    case 12:
                        _i++;
                        return [3 /*break*/, 2];
                    case 13: return [2 /*return*/];
                }
            });
        });
    };
    FacadeBuilder.prototype.collectSourceFiles = function (bundleDirName) {
        return __awaiter(this, void 0, void 0, function () {
            var functionDir, interfaceDir;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        functionDir = "./src/".concat(bundleDirName, "/functions");
                        interfaceDir = "./src/".concat(bundleDirName, "/interfaces");
                        _a = {};
                        return [4 /*yield*/, getSolidityFiles(functionDir)];
                    case 1:
                        _a.functionFiles = _b.sent();
                        return [4 /*yield*/, getSolidityFiles(interfaceDir)];
                    case 2: return [2 /*return*/, (_a.interfaceFiles = _b.sent(),
                            _a)];
                }
            });
        });
    };
    FacadeBuilder.prototype.extractFacadeObjects = function (sourceFiles, facade) {
        return __awaiter(this, void 0, void 0, function () {
            var facadeObject, regex, _i, _a, file, fileName, content, ast, _b, _c, file, fileName, content, ast;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        facadeObject = {
                            files: [],
                            errors: [],
                            events: [],
                            functions: []
                        };
                        regex = /^(I)?.*(Errors|Events)\.sol$/;
                        _i = 0, _a = sourceFiles.interfaceFiles;
                        _d.label = 1;
                    case 1:
                        if (!(_i < _a.length)) return [3 /*break*/, 4];
                        file = _a[_i];
                        fileName = path.basename(file);
                        if (!regex.test(fileName)) {
                            return [3 /*break*/, 3];
                        }
                        facadeObject.files.push({ name: fileName.replace(/\.sol$/, ""), origin: file.replace(/\\/g, '/') });
                        return [4 /*yield*/, fs.readFile(file, 'utf8')];
                    case 2:
                        content = _d.sent();
                        try {
                            ast = (0, parser_1.parse)(content, { tolerant: true });
                            // Extract functions from the AST
                            traverseASTs(ast, facadeObject, fileName, facade, true);
                        }
                        catch (err) {
                            console.error("Error parsing ".concat(file, ":"), err);
                        }
                        _d.label = 3;
                    case 3:
                        _i++;
                        return [3 /*break*/, 1];
                    case 4:
                        _b = 0, _c = sourceFiles.functionFiles;
                        _d.label = 5;
                    case 5:
                        if (!(_b < _c.length)) return [3 /*break*/, 8];
                        file = _c[_b];
                        fileName = path.basename(file);
                        // Exclude files based on facade configuration
                        if (facade.excludeFileNames.includes(fileName)) {
                            return [3 /*break*/, 7];
                        }
                        return [4 /*yield*/, fs.readFile(file, 'utf8')];
                    case 6:
                        content = _d.sent();
                        try {
                            ast = (0, parser_1.parse)(content, { tolerant: true });
                            // Extract functions from the AST
                            traverseASTs(ast, facadeObject, fileName, facade);
                        }
                        catch (err) {
                            console.error("Error parsing ".concat(file, ":"), err);
                        }
                        _d.label = 7;
                    case 7:
                        _b++;
                        return [3 /*break*/, 5];
                    case 8: return [2 /*return*/, facadeObject];
                }
            });
        });
    };
    FacadeBuilder.prototype.generateFacadeContract = function (objects, facade, config) {
        return __awaiter(this, void 0, void 0, function () {
            var facadeFilePath, code, _i, _a, file, _b, _c, error, _d, _e, event_1, _f, _g, func;
            return __generator(this, function (_h) {
                facadeFilePath = path.join(this.facadeDir, "".concat(facade.name, ".sol"));
                code = "// SPDX-License-Identifier: MIT\n    pragma solidity ^0.8.24;\n    \n    import {Schema} from \"src/".concat(config.bundleDirName, "/storage/Schema.sol\";\n    ");
                for (_i = 0, _a = objects.files; _i < _a.length; _i++) {
                    file = _a[_i];
                    code += "import {".concat(file.name, "} from \"").concat(file.origin, "\";\n");
                }
                code += "\ncontract ".concat(facade.name, " is Schema, ").concat(objects.files.map(function (file) { return file.name; }).join(', '), " {\n");
                for (_b = 0, _c = objects.errors; _b < _c.length; _b++) {
                    error = _c[_b];
                    if (error.imported) {
                        continue;
                    }
                    code += generateError(error);
                }
                code += "\n";
                for (_d = 0, _e = objects.events; _d < _e.length; _d++) {
                    event_1 = _e[_d];
                    if (event_1.imported) {
                        continue;
                    }
                    code += generateEvent(event_1);
                }
                code += "\n";
                for (_f = 0, _g = objects.functions; _f < _g.length; _f++) {
                    func = _g[_f];
                    code += generateFunctionSignature(func);
                }
                code += "}\n";
                return [2 /*return*/, code];
            });
        });
    };
    FacadeBuilder.prototype.writeFacadeContract = function (facadeName, version, code) {
        return __awaiter(this, void 0, void 0, function () {
            var facadeFilePath;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        facadeFilePath = path.join(this.facadeDir, "".concat(facadeName, "V").concat(version[0], "_").concat(version[1], "_").concat(version[2], ".sol"));
                        return [4 /*yield*/, fs.writeFile(facadeFilePath, code)];
                    case 1:
                        _a.sent();
                        console.log("Facade contract generated at ".concat(facadeFilePath));
                        return [2 /*return*/];
                }
            });
        });
    };
    return FacadeBuilder;
}());
// メイン関数を簡素化
function main() {
    return __awaiter(this, void 0, void 0, function () {
        var facadeConfigPath, facadeDir, projectRoot, builder, error_1;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    facadeConfigPath = './facade.yaml';
                    facadeDir = './generated';
                    projectRoot = path.resolve(__dirname, '../../');
                    builder = new FacadeBuilder(facadeConfigPath, facadeDir, projectRoot);
                    _a.label = 1;
                case 1:
                    _a.trys.push([1, 3, , 4]);
                    return [4 /*yield*/, builder.build()];
                case 2:
                    _a.sent();
                    return [3 /*break*/, 4];
                case 3:
                    error_1 = _a.sent();
                    console.error('Facade generation failed:', error_1);
                    process.exit(1);
                    return [3 /*break*/, 4];
                case 4: return [2 /*return*/];
            }
        });
    });
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
function validateFacadeConfig(facadeConfig) {
    // Ensure required fields are present
    if (!facadeConfig.bundleName || !facadeConfig.bundleDirName) {
        console.error('Error: bundleName and bundleDirName are required in facade.yaml');
        process.exit(1);
    }
    if (!facadeConfig.facades || facadeConfig.facades.length === 0) {
        console.error('Error: At least one facade must be defined in facade.yaml');
        process.exit(1);
    }
    for (var _i = 0, _a = facadeConfig.facades; _i < _a.length; _i++) {
        var facade = _a[_i];
        if (!facade.name) {
            console.error('Error: Each facade must have a name');
            process.exit(1);
        }
    }
}
function getSolidityFiles(dir) {
    return __awaiter(this, void 0, void 0, function () {
        var files, items, _i, items_1, item, fullPath, stat, subFiles;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    files = [];
                    return [4 /*yield*/, fs.readdir(dir)];
                case 1:
                    items = _a.sent();
                    _i = 0, items_1 = items;
                    _a.label = 2;
                case 2:
                    if (!(_i < items_1.length)) return [3 /*break*/, 7];
                    item = items_1[_i];
                    fullPath = path.join(dir, item);
                    return [4 /*yield*/, fs.stat(fullPath)];
                case 3:
                    stat = _a.sent();
                    if (!stat.isDirectory()) return [3 /*break*/, 5];
                    return [4 /*yield*/, getSolidityFiles(fullPath)];
                case 4:
                    subFiles = _a.sent();
                    files = files.concat(subFiles);
                    return [3 /*break*/, 6];
                case 5:
                    if (stat.isFile() && path.extname(item) === '.sol') {
                        files.push(fullPath);
                    }
                    _a.label = 6;
                case 6:
                    _i++;
                    return [3 /*break*/, 2];
                case 7: return [2 /*return*/, files];
            }
        });
    });
}
function getLatestVersionFile(files, baseName) {
    var regex = new RegExp("^".concat(baseName, "(?:V(\\d+)_(\\d+)_(\\d+))?\\.sol$"));
    return files
        .map(function (file) {
        var match = path.basename(file).match(regex);
        if (match) {
            var _a = match.map(Number), _ = _a[0], major = _a[1], minor = _a[2], patch = _a[3];
            return {
                file: file,
                version: [major || 1, minor || 0, patch || 0],
            };
        }
        return null;
    })
        .filter(function (item) { return item !== null; })
        .sort(function (a, b) {
        // バージョン配列を比較 (降順)
        for (var i = 0; i < 3; i++) {
            if (b.version[i] !== a.version[i]) {
                return b.version[i] - a.version[i];
            }
        }
        return 0;
    })[0] || null;
}
function getSymmetricDifference(array1, array2, keys) {
    var isMatch = function (a, b) { return keys.every(function (key) { return a[key] === b[key]; }); };
    // A ∪ B
    var union = __spreadArray(__spreadArray([], array1, true), array2, true);
    // A ∩ B
    var intersection = array1.filter(function (item1) {
        return array2.some(function (item2) { return isMatch(item1, item2); });
    });
    // A ∪ B - A ∩ B
    return union.filter(function (item) {
        return !intersection.some(function (intersectItem) { return isMatch(item, intersectItem); });
    });
}
function traverseASTs(ast, facadeObjects, origin, facade, imported) {
    if (imported === void 0) { imported = false; }
    if (ast.type === 'FunctionDefinition' && ast.isConstructor === false) {
        extractFunctions(ast, facadeObjects.functions, origin, facade);
    }
    else if (ast.type === 'ContractDefinition') {
        // Traverse contract sub-nodes
        for (var _i = 0, _a = ast.subNodes; _i < _a.length; _i++) {
            var subNode = _a[_i];
            traverseASTs(subNode, facadeObjects, origin, facade, imported);
        }
    }
    else if (ast.type === 'SourceUnit') {
        // Traverse source unit nodes
        for (var _b = 0, _c = ast.children; _b < _c.length; _b++) {
            var child = _c[_b];
            traverseASTs(child, facadeObjects, origin, facade, imported);
        }
    }
    else if (ast.type === 'CustomErrorDefinition') {
        extractErrors(ast, facadeObjects.errors, origin, imported);
    }
    else if (ast.type === 'EventDefinition') {
        extractEvents(ast, facadeObjects.events, origin, imported);
    }
}
function extractErrors(ast, errors, origin, imported) {
    var error = {
        name: ast.name,
        parameters: ast.parameters
            .map(function (param) { return getParameter(param); })
            .join(', '),
        origin: origin,
        imported: imported
    };
    errors.push(error);
}
function extractEvents(ast, events, origin, imported) {
    var event = {
        name: ast.name,
        parameters: ast.parameters
            .map(function (param) { return getParameter(param); })
            .join(', '),
        origin: origin,
        imported: imported
    };
    events.push(event);
}
function extractFunctions(ast, functions, origin, facade) {
    // Skip functions based on the criteria
    if (!ast.name || // Skip unnamed functions (constructor, fallback, receive)
        ast.name.startsWith('test') ||
        ast.name === 'setUp' ||
        ast.visibility === 'private' ||
        ast.visibility === 'internal' ||
        facade.excludeFunctionNames.includes(ast.name)) {
        return;
    }
    var func = {
        name: ast.name,
        visibility: ast.visibility || 'default',
        stateMutability: ast.stateMutability || '',
        parameters: ast.parameters
            .map(function (param) { return getParameter(param); })
            .join(', '),
        returnParameters: ast.returnParameters
            ? ast.returnParameters
                .map(function (param) { return getParameter(param); })
                .join(', ')
            : '',
        origin: origin, // Set the origin to the file name
    };
    // Add to functions array
    functions.push(func);
}
function getParameter(param) {
    var typeName = getTypeName(param.typeName);
    return "".concat(typeName).concat(param.storageLocation ? ' ' + param.storageLocation : '').concat(param.name ? ' ' + param.name : '');
}
function getTypeName(typeName) {
    if (!typeName)
        return '';
    if (typeName.type === 'ElementaryTypeName') {
        return typeName.name;
    }
    else if (typeName.type === 'UserDefinedTypeName') {
        return typeName.namePath;
    }
    else if (typeName.type === 'Mapping') {
        return "mapping(".concat(getTypeName(typeName.keyType), " => ").concat(getTypeName(typeName.valueType), ")");
    }
    else if (typeName.type === 'ArrayTypeName') {
        return "".concat(getTypeName(typeName.baseTypeName), "[]");
    }
    else if (typeName.type === 'FunctionTypeName') {
        // Simplify function type names for parameters
        return 'function';
    }
    else {
        return 'unknown';
    }
}
function generateError(error) {
    return "    error ".concat(error.name, "(").concat(error.parameters, ");\n");
}
function generateEvent(event) {
    return "    event ".concat(event.name, "(").concat(event.parameters, ");\n");
}
function generateFunctionSignature(func) {
    var visibility = func.visibility !== 'default' ? func.visibility : 'public';
    var stateMutability = func.stateMutability
        ? ' ' + func.stateMutability
        : '';
    var returns = func.returnParameters
        ? " returns (".concat(func.returnParameters, ")")
        : '';
    return "    function ".concat(func.name, "(").concat(func.parameters, ") ").concat(visibility).concat(stateMutability).concat(returns, " {}\n");
}
main().catch(function (err) {
    console.error('Error:', err);
});
