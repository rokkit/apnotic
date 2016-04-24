require 'spec_helper'

describe Apnotic::Notification do
  let(:notification) { Apnotic::Notification.new("token") }

  describe "attributes" do

    subject { notification }

    # <https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/TheNotificationPayload.html>
    describe "remote notification payload" do

      before do
        notification.alert             = "Something for you!"
        notification.badge             = 22
        notification.sound             = "sound.wav"
        notification.content_available = false
        notification.category          = "action_one"
        notification.custom_payload    = { acme1: "bar" }
      end

      it { is_expected.to have_attributes(token: "token") }
      it { is_expected.to have_attributes(alert: "Something for you!") }
      it { is_expected.to have_attributes(badge: 22) }
      it { is_expected.to have_attributes(sound: "sound.wav") }
      it { is_expected.to have_attributes(content_available: false) }
      it { is_expected.to have_attributes(category: "action_one") }
      it { is_expected.to have_attributes(custom_payload: { acme1: "bar" }) }
    end

    # <https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/APNsProviderAPI.html>
    describe "request specifics" do

      before do
        notification.id         = "apns-id"
        notification.expiration = 1461491082
        notification.priority   = 10
        notification.topic      = "com.example.myapp"
      end

      it { is_expected.to have_attributes(id: "apns-id") }
      it { is_expected.to have_attributes(expiration: 1461491082) }
      it { is_expected.to have_attributes(priority: 10) }
      it { is_expected.to have_attributes(topic: "com.example.myapp") }
    end
  end

  describe "#id" do

    before { allow(SecureRandom).to receive(:uuid) { "an-auto-generated-uid" } }

    it "is initialized as an UUID" do
      expect(notification.id).to eq "an-auto-generated-uid"
    end
  end

  describe "#body" do

    subject { notification.body }

    context "when only alert is specified" do

      before do
        notification.alert = "Something for you!"
      end

      it { eq (
        {
          aps: {
            alert: "Something for you!"
          }
        }.to_json
      ) }
    end

    context "when everything is specified" do

      before do
        notification.alert             = "Something for you!"
        notification.badge             = 22
        notification.sound             = "sound.wav"
        notification.category          = "action_one"
        notification.custom_payload    = { acme1: "bar" }
      end

      context "and content_available is true" do

        before { notification.content_available = true }

        it { eq (
          {
            aps:   {
              alert:             "Something for you!",
              badge:             22,
              sound:             "sound.wav",
              content_available: 1,
              category:          "action_one"
            },
            acme1: "bar"
          }.to_json
        ) }
      end

      context "and content_available is false" do

        before { notification.content_available = false }

        it { eq (
          {
            aps:   {
              alert:             "Something for you!",
              badge:             22,
              sound:             "sound.wav",
              content_available: 0,
              category:          "action_one"
            },
            acme1: "bar"
          }.to_json
        ) }
      end
    end
  end
end
