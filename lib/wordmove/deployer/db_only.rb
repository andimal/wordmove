require 'wordmove/deployer/base'

module Wordmove
  module Deployer
    class DB < Base

      def push_db_no_file
        super

        local_dump_path = local_wp_content_dir.path("dump.sql")
        local_backup_path = local_wp_content_dir.path("remote-backup-#{Time.now.to_i}.sql")

        # dump the remote db to local path
        save_remote_db(local_backup_path)

        # dump local db to push
        save_local_db(local_dump_path)

        # gsub sql
        adapt_sql(local_dump_path, local_options, remote_options)
        
        # import it
        run mysql_import_command(local_dump_path, remote_options[:database])

        # remove dump locally
        run "rm #{local_dump_path}"
      end

      def pull_db_no_file
        super
        local_dump_path = local_wp_content_dir.path("dump.sql")
        local_backup_path = local_wp_content_dir.path("local-backup-#{Time.now.to_i}.sql")

        save_local_db(local_backup_path)
        save_remote_db(local_dump_path)

        # gsub sql
        adapt_sql(local_dump_path, remote_options, local_options)
        # import locally
        run mysql_import_command(local_dump_path, local_options[:database])

        # remove dump locally
        run "rm #{local_dump_path}"
      end

    end
  end
end

