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
        'jquery-sparkline': 'npm:jquery-sparkline@2.3.2',
        'momentjs': 'npm:momentjs@1.1.15',
        'moment': 'npm:moment@2.15.0',
        'material-design-iconfont': 'npm:material-design-iconfont@0.1.7',
        'angular': 'npm:angular@1.5.8',
        'angular-ui-router': 'npm:angular-ui-router@1.0.0-beta.1',
        'css': 'github:systemjs/plugin-css@0.1.27',
        'jquery': 'npm:jquery@3.1.0',
        'materialize-css': 'npm:materialize-css@0.97.7',
        'os': 'github:jspm/nodelibs-os@0.2.0-alpha',
        'signalr': 'npm:signalr@2.2.1',
        'ts': 'github:frankwallis/plugin-typescript@4.0.16'
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
        }
    }
});
