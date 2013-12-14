require 'wordmove/deployer/base'

module Wordmove
  module Deployer

    def push_db
      super

      local_dump_path = local_wp_content_dir.path("dump.sql")
      remote_dump_path = remote_wp_content_dir.path("dump.sql")
      local_backup_path = local_wp_content_dir.path("remote-backup-#{Time.now.to_i}.sql")

      download_remote_db(local_backup_path)
      save_local_db(local_dump_path)

      # gsub sql
      adapt_sql(local_dump_path, local_options, remote_options)
      # upload it
      remote_put(local_dump_path, remote_dump_path)

      import_remote_dump

      # remove dump remotely
      remote_delete(remote_dump_path)
      # and locally
      run "rm #{local_dump_path}"
    end

    def pull_db
      super
      local_dump_path = local_wp_content_dir.path("dump.sql")
      local_backup_path = local_wp_content_dir.path("local-backup-#{Time.now.to_i}.sql")

      save_local_db(local_backup_path)
      download_remote_db(local_dump_path)

      # gsub sql
      adapt_sql(local_dump_path, remote_options, local_options)
      # import locally
      run mysql_import_command(local_dump_path, local_options[:database])

      # and locally
      run "rm #{local_dump_path}"
    end

  end
end
# end

