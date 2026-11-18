const fs = require('node:fs');
const path = require('node:path');

const directory = process.argv[2];
const credential = { id: 'ngsSshPasswordV1', name: 'NGS Tools SSH' };
const workflowId = 'ngsProjectAutoV1';
const readJson = (file) => JSON.parse(fs.readFileSync(file, 'utf8'));
const sshNodes = (workflow) =>
  workflow.nodes.filter((node) => node.type === 'n8n-nodes-base.ssh');

if (process.argv[3] === 'verify') {
  const credentials = readJson(path.join(directory, 'check-credential.json'));
  const [workflow] = readJson(path.join(directory, 'check-workflow.json'));
  if (!credentials.some((entry) => entry.id === credential.id && entry.type === 'sshPassword') ||
      workflow?.id !== workflowId ||
      sshNodes(workflow).length !== 17 ||
      !sshNodes(workflow).every((node) => node.credentials?.sshPassword?.id === credential.id)) {
    throw new Error('Could not verify the imported NGS workflow and SSH credential');
  }
} else {
  const password = fs.readFileSync('/run/ngs-credentials/password', 'utf8').replace(/\n$/, '');
  if (!password) throw new Error('The NGS Tools SSH password is empty');

  const workflow = readJson('/workflows/projectauto.json');
  workflow.id = workflowId;
  workflow.active = false;
  for (const node of sshNodes(workflow)) {
    node.credentials = { sshPassword: credential };
  }

  fs.writeFileSync(path.join(directory, 'credentials.json'), JSON.stringify([{
    ...credential,
    type: 'sshPassword',
    data: { host: 'ngs-tools', port: 22, username: 'root', password },
  }]), { mode: 0o600 });
  fs.writeFileSync(path.join(directory, 'workflow.json'), JSON.stringify(workflow));
}
