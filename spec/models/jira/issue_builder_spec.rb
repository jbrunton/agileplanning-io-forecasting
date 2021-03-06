require 'rails_helper'

RSpec.describe Jira::IssueBuilder do
  let(:epic_link_id) { 'customfield_12345' }
  let(:epic_status_id) { 'customfield_98765' }
  let(:story_points_id) { 'customfield_2468' }
  let(:epic_status) { 'Done' }

  describe "#build" do
    let(:json) {
      <<-END
      {
        "key": "DEMO-101",
        "fields": {
          "summary": "Some Issue",
          "issuetype": {
            "name": "Story"
          },
          "#{epic_link_id}": "EPIC-KEY",
          "#{story_points_id}": "5"
        },
        "changelog": {
          "histories": [
            {
              "created": "2015-03-05T10:30:00.000+0100",
              "items": [
                {
                  "field": "status",
                  "fromString": "To Do",
                  "toString": "In Progress"
                }
              ]
            },
            {
              "created": "2015-03-10T10:30:00.000+0100",
              "items": [
                {
                  "field": "status",
                  "fromString": "In Progress",
                  "toString": "Done"
                }
              ]
            }
          ]
        }
      }
      END
    }

    let(:issue) { Jira::IssueBuilder.new(JSON.parse(json), epic_link_id, epic_status_id, story_points_id).build }

    it "sets the key" do
      expect(issue.key).to eq('DEMO-101')
    end

    it "sets the summary" do
      expect(issue.summary).to eq('Some Issue')
    end

    it "sets the issue_type" do
      expect(issue.issue_type).to eq('Story')
    end

    it "sets the epic" do
      expect(issue.epic_key).to eq('EPIC-KEY')
    end

    it "sets the story points" do
      expect(issue.story_points).to eq(5)
    end

    context "if the issue_type is 'epic'" do
      let(:json) {
        <<-END
        {
          "key": "DEMO-101",
          "fields": {
            "summary": "Some Issue",
            "issuetype": {
              "name": "Epic"
            },
            "#{epic_status_id}": {
              "value": "EPIC_STATUS"
            }
          },
          "changelog": {
            "histories": [
              {
                "created": "2015-03-05T10:30:00.000+0100",
                "items": [
                  {
                    "field": "status",
                    "fromString": "To Do",
                    "toString": "In Progress"
                  }
                ]
              },
              {
                "created": "2015-03-10T10:30:00.000+0100",
                "items": [
                  {
                    "field": "status",
                    "fromString": "In Progress",
                    "toString": "Done"
                  }
                ]
              }
            ]
          }
        }
        END
      }

      it "sets the started and completed dates to nil" do
        issue = Jira::IssueBuilder.new(JSON.parse(json), epic_link_id, epic_status_id, story_points_id).build
        expect(issue.started).to be_nil
        expect(issue.completed).to be_nil
      end

      it "sets the epic_status" do
        expect(issue.epic_status).to eq('EPIC_STATUS')
      end
    end

    context "otherwise" do
      it "computes the started date" do
        expected_time = DateTime.parse("2015-03-05T10:30:00.000+0100")
        expect(issue.started).to eq(expected_time)
      end

      it "computes the completed date" do
        expected_time = DateTime.parse("2015-03-10T10:30:00.000+0100")
        expect(issue.completed).to eq(expected_time)
      end
    end
  end
end