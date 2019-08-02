# frozen_string_literal: true

class AwsS3
  def initialize
    Aws.config.update(
      credentials: Aws::Credentials.new(
        ENV['AWS_ACCESS_KEY_ID'],
        ENV['AWS_SECRET_ACCESS_KEY'],
      ),
    )
    resource = Aws::S3::Resource.new(region: 'us-west-1')
    @bucket = resource.bucket ENV['AWS_S3_BUCKET']
  end

  def put_torrent(path, dl_link)
    object = @bucket.object(path)
    object.put(
      body: dl_link.click.content,
      content_disposition: 'attachment',
      content_type: 'application/x-bittorrent',
      acl: 'public-read',
    ) unless object.exists?
    object.public_url
  end
end
