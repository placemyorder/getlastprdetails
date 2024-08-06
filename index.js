/**
 * Most of this code has been copied from the following GitHub Action
 * to make it simpler or not necessary to install a lot of
 * JavaScript packages to execute a shell script.
 *
 * https://github.com/ad-m/github-push-action/blob/fe38f0a751bf9149f0270cc1fe20bf9156854365/start.js
 */
const core = require('@actions/core');
const spawn = require('child_process').spawn;
const path = require("path");

const input1 = core.getInput('token');
const input2 = core.getInput('reponame');
const input3 = core.getInput('commitMessage');

const exec = (cmd, args=[]) => new Promise((resolve, reject) => {
    console.log(`Started: ${cmd} ${args.join(" ")}`)
    const app = spawn(cmd, args, { stdio: 'inherit' });
    app.on('close', code => {
        if(code !== 0){
            err = new Error(`Invalid status code: ${code}`);
            err.code = code;
            return reject(err);
        };
        return resolve(code);
    });
    app.on('error', reject);
});

const main = async () => {
    const args = [path.join(__dirname, './entrypoint.sh')];
    args.push('--token', input1);
    args.push('--repoName', input2);
    args.push('--commitMessage', input3);
    const output = await exec('bash', args);
     // Log the output (for debugging)
     core.info('Output from bash' + output)


     // Parse the output to extract the values
     const outputLines = output.split('\n');
     let prBranch = '';
     let autoIncrement = 'no';
 
     outputLines.forEach(line => {
         if (line.startsWith('PR_BRANCH=')) {
             prBranch = line.split('=')[1];
         } else if (line.startsWith('AutoIncrement=')) {
             autoIncrement = line.split('=')[1];
         }
     });
 
     // Set the outputs
     core.setOutput('PR_BRANCH', prBranch);
     core.setOutput('AutoIncrement', autoIncrement);
};

main().catch(err => {
    console.error(err);
    console.error(err.stack);
    process.exit(err.code || -1);
})