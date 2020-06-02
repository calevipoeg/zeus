# Zeus

This is a helper package for my own projects

## Installation

```ruby
gem 'calevipoeg-zeus', require: 'zeus'
```

To copy `shell` scripts into the project `/bin` folder
please run:

```bash
bundle exec zeus:copy bin/
```

## SSH Tunneling

```ruby
Zeus::SshTunnel.link('root@db-01', '5555:localhost:5432') do
  system('telnet localhost 5555')
end
```

### S3 IO

This class represents an IO object (File, StringIO) which can be
uploaded to the S3-compatible storage with PUT or multipart requests
S3Iterate
```ruby
io = Zeus::S3Io.new(File.open('movie.mp4'))
s3 = Aws::S3::Client.new

io.upload(s3, bucket: 'bucket', key: 'movies/movie.mp4') do |progress|
  puts "[#{progress.to_i}%] Uploading #{key}"
end
```

### S3 iterable

```ruby
s3 = Aws::S3::Client.new

Zeus::S3Iterate.new(s3).delete_if(bucket: 'bucket', prefix: 'movies/') do |file|
  break(false) unless 2.years.ago >= file.last_modified

  puts "[-] removing (last mod #{file.last_modified}) #{file.key}"
end
```

### PostgreSQL Base Backup

```ruby
begin
  s3 = Aws::S3::Client.new
  pg = Zeus::PgBaseBackup.new(s3: s3, bucket: 'backup')
  
  Zeus::SshTunnel.link('root@db', '5555:localhost:5432') do
    pg.dump(port: '5555', user: 'replica', password: 'password')
  end
  
  pg.upload
  pg.clear(12.days.ago)
ensure
  pg.unlink
end
```

## Mina tasks

```ruby
require 'zeus/mina/make'

invoke :make, 'docker:push'
```

```ruby
require 'zeus/mina/docker_service'

invoke :make, 'docker:push'
invoke :'docker_service:update', 'app', '--force --with-registry-auth --image http://example.com'
```

```ruby
require 'zeus/mina/s3'

set :s3_client, -> do
  Aws::S3::Client.new
end

set :s3_bucket, -> do
  'hole' 
end

invoke :'s3:upload', ["public/static"], "cdn/production/static"
invoke :'s3:clean', 'cdn/production/static', 14.days.ago
```
