require 'rubygems'  
require 'active_support/all'
require 'sinatra'
require 'haml'
require 'signalcloud.rb' #, git: 'https://github.com/illoyd/signalcloud.rb'

ORGANIZATION_ID = 1
STENCIL_ID      = 2
SERVICE_URI     = 'https://eu.signalcloudapp.com'

##
# Icons for icon helper, for global management and access. May move into more efficient library later.
ICONS = {
  # Conversation statuses
  confirmed: 'check-circle-o',
  denied: 'minus-circle',
  failed: 'times-circle-o',
  expired: 'clock-o',
  pending: 'plus-circle',
  asking: 'question-circle',
  asked: 'question-circle',
  received: 'exclamation-circle',
  challenge_sent: 'plus-circle',
  draft: 'file-text-o',

  error: 'exclamation-triangle'
}.freeze

def client( username=nil, password=nil )
  SignalCloud::Client.new( username, password, base_uri: SERVICE_URI )
end

def icon( kind = :blank, options = {} )
  #render partial: 'layouts/icon', object: ICONS.fetch( kind, kind ).to_s, locals: { options: options }
  kind = ICONS.fetch( kind, kind ).to_s

  i_class = options.fetch(:class, '')
  i_class = i_class.concat(' ') if i_class.is_a?(Array)

  i_style = options.fetch(:style, '')
  i_style = i_style.concat(' ') if i_style.is_a?(Array)

  return "<i class='fa fa-#{kind.to_s} #{i_class}' style='#{i_style}'></i>"
end

def conversation_state_icon( state, options = {} )
  icon( conversation_state( state ), options )
end

def conversation_state( state )
  case state.to_sym
    when :confirming, :confirmed
      :confirmed
    when :denying, :denied
      :denied
    when :failing, :failed
      :failed
    when :expiring, :expired
      :expired
    when :asking
      :asking
    when :asked
      :asked
    when :receiving, :received
      :received
    when :draft
      :draft
    when :errored
      :error
  end
end

error do
  haml :error
end

# Start page
get '/' do
  haml :index
end

# Start conversation
post '/' do
  redirect '/' if params[:customer_number].blank?

  # Start the conversation
  @conversation = client().start_conversation( ORGANIZATION_ID, stencil_id: STENCIL_ID, customer_number: params[:customer_number] )
  redirect "/#{@conversation.id}"
end

# View page
get '/:id' do
  # Get info from client`
  @conversation = client().conversation(ORGANIZATION_ID, params[:id])
  #@conversation.to_json
  haml :show
end
