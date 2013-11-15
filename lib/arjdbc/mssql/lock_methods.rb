module ArJdbc
  module MSSQL
    module LockMethods

      MSSQL_TABLE = /(\[[^\]]+\]\.\[^\]\]\.)?\[[^\]]+\]/ # Table can be precedeed by database name and owner
      MSSQL_TABLE_WITH_ALIAS = /#{MSSQL_TABLE}( \[[^\]]+\])?/

      # Microsoft SQL Server uses its own syntax for SELECT .. FOR UPDATE:
      # SELECT .. FROM table1 WITH(ROWLOCK,UPDLOCK), table2 WITH(ROWLOCK,UPDLOCK) WHERE ..
      #
      # This does in-place modification of the passed-in string.
      def add_lock!(request, options)
        if (lock = options[:lock])
          # replace the default option with the default option for SQLServer
          hint = (lock == true || lock.expr == 'FOR UPDATE' ? 'WITH(UPDLOCK)' : "(#{lock.expr})")

          # Replace select * from [table] with select * from [table] (hint)
          request.gsub! /select (.*) from (#{MSSQL_TABLE_WITH_ALIAS})/i, "SELECT \\1 FROM \\2 #{hint}"

          # Replace join [table] with join [table] (hint)
          # Replace join [table] [alias] with join [table] [alias] (hint)
          request.gsub! /join (#{MSSQL_TABLE_WITH_ALIAS})/i, "JOIN \\1 #{hint}" # Single \ with '

          # Replace UPDATE [table] with UPDATE [table] (hint)
          request.gsub! /update (#{MSSQL_TABLE_WITH_ALIAS})/i, "UPDATE \\1 WITH#{hint}" # Double \ with "

          # Replace delete from [table] with delete from [table] with(hint)
          request.gsub! /delete from (#{MSSQL_TABLE_WITH_ALIAS})/i, "DELETE FROM \\1 WITH#{hint}" # Double \ with "
        end

        request
      end

    end
  end
end
