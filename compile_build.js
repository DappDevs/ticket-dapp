const path = require('path');
const fs = require('fs-extra');
const solc = require('solc');

const contractPath = path.resolve(__dirname, 'contracts');
const buildPath = path.resolve(__dirname, 'build');

var buildAll = function (dir) {
    fs.readdir(dir, function (error, list) {
        if (error) {
            console.log('error reading directory', error);
        }

        var i = 0;

        (function next () {
            var file = list[i++];

            if (!file) {
                return;
            }
            
            file = dir + '/' + file;
            
            fs.stat(file, function (error, stat) {
        
                if (stat && !stat.isDirectory()) {

                    // const contractFilePath = path.resolve(__dirname, 'contracts', contract+'.sol');
                    const source = fs.readFileSync(file, 'utf8');

                    // output compiled contracts
                    const output = solc.compile(source, 1).contracts;

                    //console.log(output);
                    for (let contract in output) {
                        fs.outputJsonSync(
                            path.resolve(buildPath, contract.replace(':','') +'.json'),
                            output[contract]
                        );
                    }

                    next();
                }
            });
        })();
    });
};

// Cleanup.. rm -r ../build
fs.removeSync(buildPath);

// Create the directory (again)
fs.ensureDirSync(buildPath);

buildAll( contractPath )
