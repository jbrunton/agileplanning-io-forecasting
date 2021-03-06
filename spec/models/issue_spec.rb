require 'rails_helper'

RSpec.describe Issue, type: :model do
  let(:dashboard) { create(:dashboard) }

  describe "#size" do
    context "if the issue has story points" do
      it "returns the size" do
        issue = create(:issue, story_points: 3, dashboard: dashboard)
        expect(issue.size).to eq(3)
      end
    end

    context "if the epic has a t-shirt-size" do
      it "returns the size" do
        epic = create(:epic, summary: "Small Epic [S]", dashboard: dashboard)
        expect(epic.size).to eq('S')
      end
    end

    context "if the epic has no t-shirt-size" do
      it "returns nil" do
        epic = create(:epic, summary: "Unsized Epic", dashboard: dashboard)
        expect(epic.size).to be_nil
      end
    end
  end

  describe "#completed?" do
    context "for stories" do
      it "returns false if #completed is nil" do
        story = create(:issue)
        expect(story.completed?).to eq(false)
      end

      it "returns true otherwise" do
        story = create(:issue, :completed)
        expect(story.completed?).to eq(true)
      end
    end

    context "for epics" do
      it "returns true if epic_status is 'Done'" do
        epic = create(:epic, epic_status: 'Done')
        expect(epic.completed?).to eq(true)
      end

      it "returns false otherwise" do
        epic = create(:epic, :completed, epic_status: nil)
        expect(epic.completed?).to eq(false)
      end
    end
  end
end
