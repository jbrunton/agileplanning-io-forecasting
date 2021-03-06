class Jira::IssueBuilder
  def initialize(json, epic_link_id, epic_status_id, story_points_id)
    @json = json
    @epic_link_id = epic_link_id
    @epic_status_id = epic_status_id
    @story_points_id = story_points_id
  end

  def build
    attrs = {
        :key => key,
        :summary => summary,
        :issue_type => issue_type,
        :epic_status => epic_status,
        :story_points => story_points
    }

    unless attrs[:issue_type] == 'Epic'
      attrs[:started] = compute_started_date
      attrs[:completed] = compute_completed_date
      attrs[:epic_key] = epic_key
    end

    Issue.new(attrs)
  end

private
  def key
    @json['key']
  end

  def summary
    @json['fields']['summary']
  end

  def issue_type
    @json['fields']['issuetype']['name']
  end

  def epic_key
    @json['fields'][@epic_link_id]
  end

  def epic_status
    @json['fields'][@epic_status_id].try(:[], 'value')
  end

  def story_points
    story_points_str = @json['fields'][@story_points_id]
    story_points_str.to_i if story_points_str
  end

  def compute_started_date
    return nil unless @json['changelog']

    started_transitions = @json['changelog']['histories'].select do |entry|
      entry['items'].any?{|item| is_started_transition(item)}
    end

    if started_transitions.any?
      started_transitions.first['created']
    else
      nil
    end
  end

  def compute_completed_date
    return nil unless @json['changelog']

    last_transition = @json['changelog']['histories'].select do |entry|
      entry['items'].any?{|item| is_status_transition(item)}
    end.last

    if !last_transition.nil? &&
        last_transition['items'].any?{|item| is_completed_transition(item)}
      last_transition['created']
    else
      nil
    end
  end

  def is_status_transition(item)
    item['field'] == "status"
  end

  def is_started_transition(item)
    is_status_transition(item) &&
        (item['toString'] == "In Progress" || item['toString'] == "Started")
  end

  def is_completed_transition(item)
    is_status_transition(item) &&
        (item['toString'] == "Done" || item['toString'] == "Closed")
  end
end