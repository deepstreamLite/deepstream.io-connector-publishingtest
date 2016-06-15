# deepstream.io-connector-publishingtest

This repo is used by all other connectors for the following:

## Packaging

This creates a clean package to upload to S3 on every commit and attaches the result
to github releases on a tag

## Testing

This tests the package works against the specified bundled platform distribution by:

1) Downloading deepstream
2) Running `deepstream install <type> <name>:<tag>`
2) Starting deepstream with config `deepstream start -c ../../example-config.yml'
3) Ensuring process is still running after ten seconds ( which means it connected succesfuly )