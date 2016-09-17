SystemJS.config({
    devConfig: {
        'map': {
            'angular-mocks': 'npm:angular-mocks@1.5.8'
        }
    },
    packages: {
        'src': {
            'defaultExtension': 'ts'
        },
        'typings': {
            'defaultExtension': 'ts'
        },
        '.tmp': {
            'defaultExtension': 'ts'
        }
    },
    transpiler: 'ts',
    typescriptOptions: {
        'sourceMap': true,
        'emitDecoratorMetadata': true,
        'experimentalDecorators': true,
        'removeComments': false,
        'noImplicitAny': false
    },
    meta: {
        '*.css': {
            'loader': 'css'
        }
    },
    map: {
        'ui-router-state-events': 'npm:angular-ui-router@1.0.0-beta.1/release/stateEvents.min.js'
    }
});

SystemJS.config({
    packageConfigPaths: [
        'npm:@*/*.json',
        'npm:*.json',
        'github:*/*.json'
    ],
    map: {
        'typescript-collections': 'npm:typescript-collections@1.1.4',
        'angular-nvd3': 'github:krispo/angular-nvd3@1.0.9',
        'angular': 'github:angular/bower-angular@1.5.8',
        'angular/bower-angular': 'github:angular/bower-angular@1.5.8',
        'chartist': 'npm:chartist@0.9.8',
        'chartjs': 'npm:chartjs@0.3.24',
        'd3': 'npm:d3@3.5.17',
        'assert': 'github:jspm/nodelibs-assert@0.2.0-alpha',
        'buffer': 'github:jspm/nodelibs-buffer@0.2.0-alpha',
        'child_process': 'github:jspm/nodelibs-child_process@0.2.0-alpha',
        'constants': 'github:jspm/nodelibs-constants@0.2.0-alpha',
        'crypto': 'github:jspm/nodelibs-crypto@0.2.0-alpha',
        'events': 'github:jspm/nodelibs-events@0.2.0-alpha',
        'fs': 'github:jspm/nodelibs-fs@0.2.0-alpha',
        'http': 'github:jspm/nodelibs-http@0.2.0-alpha',
        'https': 'github:jspm/nodelibs-https@0.2.0-alpha',
        'path': 'github:jspm/nodelibs-path@0.2.0-alpha',
        'stream': 'github:jspm/nodelibs-stream@0.2.0-alpha',
        'string_decoder': 'github:jspm/nodelibs-string_decoder@0.2.0-alpha',
        'font-awesome': 'npm:font-awesome@4.6.3',
        'process': 'github:jspm/nodelibs-process@0.2.0-alpha',
        'moment': 'npm:moment@2.15.0',
        'jquery-sparkline': 'npm:jquery-sparkline@2.3.2',
        'material-design-iconfont': 'npm:material-design-iconfont@0.1.7',
        'angular-ui-router': 'npm:angular-ui-router@1.0.0-beta.1',
        'css': 'github:systemjs/plugin-css@0.1.27',
        'jquery': 'npm:jquery@3.1.0',
        'materialize-css': 'npm:materialize-css@0.97.7',
        'os': 'github:jspm/nodelibs-os@0.2.0-alpha',
        'signalr': 'npm:signalr@2.2.1',
        'ts': 'github:frankwallis/plugin-typescript@4.0.16',
        'url': 'github:jspm/nodelibs-url@0.2.0-alpha',
        'util': 'github:jspm/nodelibs-util@0.2.0-alpha',
        'vm': 'github:jspm/nodelibs-vm@0.2.0-alpha'
    },
    packages: {
        'github:frankwallis/plugin-typescript@4.0.16': {
            'map': {
                'typescript': 'npm:typescript@1.8.10'
            }
        },
        'github:jspm/nodelibs-os@0.2.0-alpha': {
            'map': {
                'os-browserify': 'npm:os-browserify@0.2.1'
            }
        },
        'npm:signalr@2.2.1': {
            'map': {
                'jquery': 'npm:jquery@3.1.0'
            }
        },
        'npm:materialize-css@0.97.7': {
            'map': {
                'css': 'github:systemjs/plugin-css@0.1.27',
                'jquery': 'github:components/jquery@3.1.0'
            }
        },
        'npm:font-awesome@4.6.3': {
            'map': {
                'css': 'github:systemjs/plugin-css@0.1.27'
            }
        },
        'github:jspm/nodelibs-http@0.2.0-alpha': {
            'map': {
                'http-browserify': 'npm:stream-http@2.4.0'
            }
        },
        'github:jspm/nodelibs-url@0.2.0-alpha': {
            'map': {
                'url-browserify': 'npm:url@0.11.0'
            }
        },
        'npm:stream-http@2.4.0': {
            'map': {
                'inherits': 'npm:inherits@2.0.3',
                'builtin-status-codes': 'npm:builtin-status-codes@2.0.0',
                'xtend': 'npm:xtend@4.0.1',
                'readable-stream': 'npm:readable-stream@2.1.5',
                'to-arraybuffer': 'npm:to-arraybuffer@1.0.1'
            }
        },
        'npm:readable-stream@2.1.5': {
            'map': {
                'inherits': 'npm:inherits@2.0.3',
                'buffer-shims': 'npm:buffer-shims@1.0.0',
                'string_decoder': 'npm:string_decoder@0.10.31',
                'core-util-is': 'npm:core-util-is@1.0.2',
                'util-deprecate': 'npm:util-deprecate@1.0.2',
                'isarray': 'npm:isarray@1.0.0',
                'process-nextick-args': 'npm:process-nextick-args@1.0.7'
            }
        },
        'npm:url@0.11.0': {
            'map': {
                'querystring': 'npm:querystring@0.2.0',
                'punycode': 'npm:punycode@1.3.2'
            }
        },
        'github:jspm/nodelibs-buffer@0.2.0-alpha': {
            'map': {
                'buffer-browserify': 'npm:buffer@4.9.1'
            }
        },
        'npm:buffer@4.9.1': {
            'map': {
                'isarray': 'npm:isarray@1.0.0',
                'base64-js': 'npm:base64-js@1.1.2',
                'ieee754': 'npm:ieee754@1.1.6'
            }
        },
        'github:jspm/nodelibs-crypto@0.2.0-alpha': {
            'map': {
                'crypto-browserify': 'npm:crypto-browserify@3.11.0'
            }
        },
        'npm:crypto-browserify@3.11.0': {
            'map': {
                'inherits': 'npm:inherits@2.0.3',
                'create-ecdh': 'npm:create-ecdh@4.0.0',
                'diffie-hellman': 'npm:diffie-hellman@5.0.2',
                'browserify-cipher': 'npm:browserify-cipher@1.0.0',
                'browserify-sign': 'npm:browserify-sign@4.0.0',
                'public-encrypt': 'npm:public-encrypt@4.0.0',
                'create-hash': 'npm:create-hash@1.1.2',
                'create-hmac': 'npm:create-hmac@1.1.4',
                'randombytes': 'npm:randombytes@2.0.3',
                'pbkdf2': 'npm:pbkdf2@3.0.6'
            }
        },
        'npm:diffie-hellman@5.0.2': {
            'map': {
                'randombytes': 'npm:randombytes@2.0.3',
                'bn.js': 'npm:bn.js@4.11.6',
                'miller-rabin': 'npm:miller-rabin@4.0.0'
            }
        },
        'npm:browserify-sign@4.0.0': {
            'map': {
                'inherits': 'npm:inherits@2.0.3',
                'create-hash': 'npm:create-hash@1.1.2',
                'create-hmac': 'npm:create-hmac@1.1.4',
                'bn.js': 'npm:bn.js@4.11.6',
                'parse-asn1': 'npm:parse-asn1@5.0.0',
                'browserify-rsa': 'npm:browserify-rsa@4.0.1',
                'elliptic': 'npm:elliptic@6.3.2'
            }
        },
        'npm:pbkdf2@3.0.6': {
            'map': {
                'create-hmac': 'npm:create-hmac@1.1.4'
            }
        },
        'npm:public-encrypt@4.0.0': {
            'map': {
                'create-hash': 'npm:create-hash@1.1.2',
                'randombytes': 'npm:randombytes@2.0.3',
                'bn.js': 'npm:bn.js@4.11.6',
                'parse-asn1': 'npm:parse-asn1@5.0.0',
                'browserify-rsa': 'npm:browserify-rsa@4.0.1'
            }
        },
        'npm:create-ecdh@4.0.0': {
            'map': {
                'bn.js': 'npm:bn.js@4.11.6',
                'elliptic': 'npm:elliptic@6.3.2'
            }
        },
        'npm:create-hash@1.1.2': {
            'map': {
                'inherits': 'npm:inherits@2.0.3',
                'ripemd160': 'npm:ripemd160@1.0.1',
                'sha.js': 'npm:sha.js@2.4.5',
                'cipher-base': 'npm:cipher-base@1.0.3'
            }
        },
        'npm:create-hmac@1.1.4': {
            'map': {
                'create-hash': 'npm:create-hash@1.1.2',
                'inherits': 'npm:inherits@2.0.3'
            }
        },
        'npm:browserify-cipher@1.0.0': {
            'map': {
                'browserify-des': 'npm:browserify-des@1.0.0',
                'evp_bytestokey': 'npm:evp_bytestokey@1.0.0',
                'browserify-aes': 'npm:browserify-aes@1.0.6'
            }
        },
        'npm:miller-rabin@4.0.0': {
            'map': {
                'bn.js': 'npm:bn.js@4.11.6',
                'brorand': 'npm:brorand@1.0.6'
            }
        },
        'npm:browserify-rsa@4.0.1': {
            'map': {
                'bn.js': 'npm:bn.js@4.11.6',
                'randombytes': 'npm:randombytes@2.0.3'
            }
        },
        'npm:parse-asn1@5.0.0': {
            'map': {
                'create-hash': 'npm:create-hash@1.1.2',
                'browserify-aes': 'npm:browserify-aes@1.0.6',
                'evp_bytestokey': 'npm:evp_bytestokey@1.0.0',
                'pbkdf2': 'npm:pbkdf2@3.0.6',
                'asn1.js': 'npm:asn1.js@4.8.0'
            }
        },
        'github:jspm/nodelibs-stream@0.2.0-alpha': {
            'map': {
                'stream-browserify': 'npm:stream-browserify@2.0.1'
            }
        },
        'npm:cipher-base@1.0.3': {
            'map': {
                'inherits': 'npm:inherits@2.0.3'
            }
        },
        'npm:sha.js@2.4.5': {
            'map': {
                'inherits': 'npm:inherits@2.0.3'
            }
        },
        'npm:browserify-des@1.0.0': {
            'map': {
                'inherits': 'npm:inherits@2.0.3',
                'cipher-base': 'npm:cipher-base@1.0.3',
                'des.js': 'npm:des.js@1.0.0'
            }
        },
        'npm:evp_bytestokey@1.0.0': {
            'map': {
                'create-hash': 'npm:create-hash@1.1.2'
            }
        },
        'npm:elliptic@6.3.2': {
            'map': {
                'bn.js': 'npm:bn.js@4.11.6',
                'inherits': 'npm:inherits@2.0.3',
                'brorand': 'npm:brorand@1.0.6',
                'hash.js': 'npm:hash.js@1.0.3'
            }
        },
        'npm:browserify-aes@1.0.6': {
            'map': {
                'create-hash': 'npm:create-hash@1.1.2',
                'inherits': 'npm:inherits@2.0.3',
                'cipher-base': 'npm:cipher-base@1.0.3',
                'evp_bytestokey': 'npm:evp_bytestokey@1.0.0',
                'buffer-xor': 'npm:buffer-xor@1.0.3'
            }
        },
        'npm:stream-browserify@2.0.1': {
            'map': {
                'inherits': 'npm:inherits@2.0.3',
                'readable-stream': 'npm:readable-stream@2.1.5'
            }
        },
        'npm:asn1.js@4.8.0': {
            'map': {
                'bn.js': 'npm:bn.js@4.11.6',
                'inherits': 'npm:inherits@2.0.3',
                'minimalistic-assert': 'npm:minimalistic-assert@1.0.0'
            }
        },
        'github:jspm/nodelibs-string_decoder@0.2.0-alpha': {
            'map': {
                'string_decoder-browserify': 'npm:string_decoder@0.10.31'
            }
        },
        'npm:hash.js@1.0.3': {
            'map': {
                'inherits': 'npm:inherits@2.0.3'
            }
        },
        'npm:des.js@1.0.0': {
            'map': {
                'inherits': 'npm:inherits@2.0.3',
                'minimalistic-assert': 'npm:minimalistic-assert@1.0.0'
            }
        },
        'github:krispo/angular-nvd3@1.0.9': {
            'map': {
                'nvd3': 'npm:nvd3@1.8.4',
                'angular': 'github:angular/bower-angular@1.5.8'
            }
        }
    }
});
