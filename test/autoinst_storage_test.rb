#!/usr/bin/env rspec

require_relative "test_helper"
Yast.import "AutoinstStorage"

describe Yast::AutoinstStorage do
  subject { Yast::AutoinstStorage }

  describe "#Import" do
    let(:profile) do
      { "proposal" => {} }
    end

    let(:proposal_settings_class) { double("ProposalSettingsClass") }
    let(:proposal_settings) { double("proposal_settings") }

    let(:proposal_class) { double("ProposalClass") }
    let(:proposal) { double("proposal", propose: nil, proposed?: true) }

    let(:storage_manager_class) { double("storage_manager_class", instance: storage_manager) }
    let(:storage_manager) { double("storage_manager") }

    before do
      stub_const("Y2Storage::ProposalSettings", proposal_settings_class)
      stub_const("Y2Storage::Proposal", proposal_class)
      stub_const("Y2Storage::StorageManager", storage_manager_class)
      allow(proposal_settings_class).to receive(:new).and_return(proposal_settings)
      allow(proposal_class).to receive(:new).with(settings: proposal_settings)
        .and_return(proposal)
    end

    it "sets the proposal" do
      expect(storage_manager).to receive(:proposal=).with(proposal)
      subject.Import(profile)
    end

    context "if proposal fails" do
      before do
        allow(proposal).to receive(:proposed?).and_return(false)
      end

      it "does not set the proposal" do
        expect(storage_manager).to_not receive(:proposal=)
        subject.Import(profile)
      end
    end

    context "when profile is nil" do
      it "creates a proposal with default settings" do
        expect(storage_manager).to receive(:proposal=).with(proposal)
        subject.Import(nil)
      end
    end

    context "when profile is empty" do
      it "creates a proposal with default settings" do
        expect(storage_manager).to receive(:proposal=).with(proposal)
        subject.Import({})
      end
    end

    context "when profile is not empty but does not contains proposal settings" do
      it "creates a proposal with not settings" do
        expect(proposal_settings_class).to_not receive(:new)
        subject.Import("partitioning" => [])
      end
    end
  end
end
