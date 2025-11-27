class Api::WorkTooling::PlatformSyncController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate, only: [:sync_notion_task_to_asana_task]

  def sync_notion_task_to_asana_task
    asana_access_token = ENV['ASANA_ACCESS_TOKEN']
    asana_workspace_id = ENV['ASANA_WORKSPACE_ID']
    asana_project_id = ENV['ASANA_PROJECT_ID']
    asana_task_name = params["data"]["properties"]["Task"]["title"][0]["plain_text"]
    asana_task_description = params["data"]["url"]
  
    endpoint = "https://app.asana.com/api/1.0/tasks"
    headers = {
      'Authorization' => "Bearer #{asana_access_token}",
      'Content-Type' => 'application/json'
    }
    body = {
      'data' => {
        'workspace' => asana_workspace_id,
        'projects' => [asana_project_id],
        'name' => asana_task_name,
        'notes' => asana_task_description
      }
    }
    response = HTTParty.post(endpoint, headers: headers, body: body.to_json)
    
    if response.success?
      render json: { success: true, message: "Notion task synced to asana task" }, status: :ok
    else
      render json: { success: false, message: "Failed to sync notion task to asana task" }, status: :unprocessable_entity
    end
  end

  def authenticate
    # check the request header for the authorization token
    authorization_header = request.headers['Authorization']
    if authorization_header.blank?
      render json: { success: false, message: "Authorization token is required" }, status: :unauthorized
      return
    else 
      # check the authorization token against the environment variable
      if authorization_header != ENV['WORK_TOOLING_NOTION_API_KEY']
        render json: { success: false, message: "Invalid authorization token" }, status: :unauthorized
        return
      else
        return
      end
    end
  end
end