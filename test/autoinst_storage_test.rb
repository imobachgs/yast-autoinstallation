#!/usr/bin/env rspec

require_relative "test_helper"
Yast.import "AutoinstStorage"

describe Yast::AutoinstStorage do
  subject { Yast::AutoinstStorage }

  describe "#Import" do
    let(:profile) do
      { "proposal" => { "use_lvm" => true } }
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
      allow(proposal_settings_class).to receive(:new_for_current_product).and_return(proposal_settings)
      allow(proposal_class).to receive(:new).with(settings: proposal_settings)
        .and_return(proposal)
      allow(storage_manager).to receive(:proposal=)
      allow(proposal_settings).to receive(:use_lvm=)
    end

    it "sets the proposal" do
      expect(storage_manager).to receive(:proposal=).with(proposal)
      subject.Import(profile)
    end

    it "builds a proposal with given options" do
      expect(proposal_settings).to receive(:use_lvm=).with(true)
      subject.Import(profile)
    end

    it "returns true" do
      expect(subject.Import(profile)).to eq(true)
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
      let(:profile) { nil }

      it "creates a proposal with default settings" do
        expect(storage_manager).to receive(:proposal=).with(proposal)
        subject.Import(profile)
      end
    end

    context "when profile is empty" do
      let(:profile) { {} }

      it "creates a proposal with default settings" do
        expect(storage_manager).to receive(:proposal=).with(proposal)
        subject.Import(profile)
      end
    end

    context "when profile contains an empty set of partitions" do
      let(:profile) { [] }

      it "builds a proposal" do
        expect(storage_manager).to receive(:proposal=).with(proposal)
        subject.Import(profile)
      end
    end

    context "when profile contains a set of partitions" do
      let(:profile) { [{"device" => "/dev/sda"}] }

      it "does not build a proposal" do
        expect(proposal_settings_class).to_not receive(:new)
        subject.Import(profile)
      end

      it "returns false" do
        expect(subject.Import(profile)).to eq(false)
      end
    end
  end
end
