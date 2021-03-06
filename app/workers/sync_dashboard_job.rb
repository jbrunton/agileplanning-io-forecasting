class SyncDashboardJob
  include Celluloid

  def sync_dashboard(dashboard, params)
    dashboard.issues.destroy_all

    jira_client = Jira::Client.new(dashboard.domain.domain, params.permit(:username, :password))
    rapid_board = jira_client.get_rapid_board(dashboard.board_id)

    issues = jira_client.search_issues(query: rapid_board.query, expand: ['changelog']) do |progress|
      WebsocketRails["dashboard:#{dashboard.id}"].trigger(:update, { progress: progress })
    end

   ActiveRecord::Base.transaction do
      issues.each do |issue|
        dashboard.issues.append(issue)
      end

      dashboard.last_synced = DateTime.now
      dashboard.save
   end

    dashboard.compute_cycle_times!
  end
end