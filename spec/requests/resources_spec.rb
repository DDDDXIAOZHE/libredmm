# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Resources", type: :request do
  let(:resource) { create :resource }
  let(:user) { create :user }
  let(:admin) { create :admin }

  describe "GET /resources/:resource_id" do
    context "when signed out" do
      it "redirects to sign in page" do
        get resource_url(resource)
        expect(response).to redirect_to(sign_in_url)
      end
    end

    context "when signed in" do
      it "redirects to root" do
        get resource_url(resource, as: user)
        expect(response).to redirect_to(root_url)
      end
    end

    context "when signed in as admin" do
      it "redirects to download uri" do
        get resource_url(resource, as: admin)
        expect(response).to redirect_to(resource.download_uri)
      end

      context "and not voted yet" do
        it "bookmarks the movie" do
          expect {
            get resource_url(resource, as: admin)
          }.to change {
            Vote.count
          }.by(1)
          expect(resource.movie.votes.where(user: admin).first.status).to(
            eq("bookmark"),
          )
        end
      end

      context "and already voted" do
        before :each do
          create :vote, user: admin, movie: resource.movie, status: :up
        end

        it "does not vote again" do
          expect {
            get resource_url(resource, as: admin)
          }.not_to change {
            resource.movie.votes.where(user: admin).first
          }
        end
      end
    end
  end

  describe "DELETE /resources/:resource_id" do
    context "when signed out" do
      it "redirects to sign in page" do
        delete resource_url(resource)
        expect(response).to redirect_to(sign_in_url)
      end

      it "does not mark resource as obselete" do
        expect {
          delete resource_url(resource)
        }.not_to change {
          resource.reload.is_obsolete?
        }
      end
    end

    context "when signed in" do
      it "redirects to root" do
        delete resource_url(resource, as: user)
        expect(response).to redirect_to(root_url)
      end

      it "does not touch resource" do
        expect {
          delete resource_url(resource, as: user)
        }.not_to change {
          resource.reload
        }
      end
    end

    context "when signed in as admin" do
      it "redirects to movie page" do
        delete resource_url(resource, as: admin)
        expect(response).to redirect_to(resource.movie)
      end

      it "marks resource as obselete" do
        expect {
          delete resource_url(resource, as: admin)
        }.to change {
          resource.reload.is_obsolete?
        }.from(false).to(true)
      end

      context "and bookmarked" do
        it "removes the bookmark" do
          create :vote, user: admin, movie: resource.movie, status: :bookmark
          delete resource_url(resource, as: admin)
          expect(resource.movie.votes.where(user: admin)).not_to exist
        end
      end

      context "and voted" do
        it "leaves the vote" do
          create :vote, user: admin, movie: resource.movie, status: :up
          delete resource_url(resource, as: admin)
          expect(resource.movie.votes.where(user: admin)).to exist
        end
      end
    end
  end
end
