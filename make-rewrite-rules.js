const csv = require('fast-csv');

process.stdout.write('<RoutingRules>\n');

const stream = csv
  .parse()
  .on('data', function (data) {
    process.stdout.write(`
  <RoutingRule>
    <Condition>
      <KeyPrefixEquals>${data[0].replace(/^\//, '')}</KeyPrefixEquals>
    </Condition>
    <Redirect>
      <HostName>team.goodeggs.com</HostName>
      <Protocol>https</Protocol>
      <HttpRedirectCode>301</HttpRedirectCode>
      <ReplaceKeyWith>${data[1].replace(/^\//, '')}</ReplaceKeyWith>
    </Redirect>
  </RoutingRule>
`);
  })
  .on('end', function () {
    process.stdout.write('</RoutingRules>\n');
    process.exit(0);
  });

process.stdin.pipe(stream);

