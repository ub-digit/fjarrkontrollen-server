require 'rails_helper'

RSpec.describe User, :type => :model do
  before :all do
  end

  it "should save a complete user" do
    user = User.new(xkonto: "valid_username", name: "Test User")
    expect(user.save).to be_truthy
  end

  it "should require xkonto" do
    user = User.new(name: "Test User")
    expect(user.save).to be_falsey
  end

  it "should have unique xkonto" do
    user = User.new(xkonto: "valid_username", name: "Test User")
    expect(user.save).to be_truthy
    user = User.new(xkonto: "valid_username", name: "Test User")
    expect(user.save).to be_falsey
  end

  it "should require name" do
    user = User.new(xkonto: "valid_username")
    expect(user.save).to be_falsey
  end
 
  it "should authenticate credentials" do
    user = User.new(xkonto: "valid_username", name: "Test User")
    user.save
    expect(user.authenticate("valid_password")).to be_truthy
  end

  it "should fail authentication on bad credentials" do
    user = User.new(xkonto: "valid_username", name: "Test User")
    user.save
    expect(user.authenticate("wrong")).to be_falsey
  end

  it "should generate token with expire time on authentication" do
    user = User.new(xkonto: "valid_username", name: "Test User")
    user.save
    expect(user.access_tokens).to be_empty
    expect(user.authenticate("valid_password")).to be_truthy
    expect(user.access_tokens).to_not be_empty
    expect(user.access_tokens.first.token_expire).to be_within(1.day+2.hours).of(Time.now)
  end

  it "should not generate token on failed authentication" do
    user = User.new(xkonto: "valid_username", name: "Test User")
    user.save
    expect(user.access_tokens).to be_empty
    expect(user.authenticate("wrong")).to be_falsey
    expect(user.access_tokens).to be_empty
  end

  it "should validate token" do
    user = User.new(xkonto: "valid_username", name: "Test User")
    user.save
    expect(user.authenticate("valid_password")).to be_truthy
    token = user.access_tokens.first.token
    expect(user.validate_token(token)).to be_truthy
  end

  it "should clear token when validating if expired" do
    user = User.new(xkonto: "valid_username", name: "Test User")
    user.save
    expect(user.authenticate("valid_password")).to be_truthy
    token = user.access_tokens.first.token
    expect(user.validate_token(token)).to be_truthy
    expect(user.access_tokens.first.token_expire).to be_within(1.day+2.hours).of(Time.now)
    user.access_tokens.first.update_attribute(:token_expire, Time.now - 1.day)
    expect(user.access_tokens.first.token_expire).to_not be_within(1.day).of(Time.now)
    expect(user.validate_token(token)).to be_falsey
    expect(user.access_tokens.first).to be_nil
  end

end
