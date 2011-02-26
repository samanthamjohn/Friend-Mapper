class UsersController < ApplicationController
  # GET /users
  # GET /users.xml
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  def publish_story
    @user = User.find(params[:id])
    @user.wall_post
    respond_to do |format| 
      format.html {render :action => 'new'}
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    @map = @user.map
  end

  def sample_ajax
    @location = params[:location]
    @names = params[:names].split(" ")
     respond_to do |format|
        format.html # index.html.erb
      end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
      @facebook_url = FacebookUrl
      p 'fb url'
      puts @facebook_url
      token_info = FacebookAuth.get_user_info_from_cookies(cookies)
      puts "cookies: #{cookies.inspect}"
    if (token_info)
      p 'cookie token'
      @user = User.add_facebook(token_info)
      redirect_to :action => 'show', :id => @user.id
    elsif (params[:code]) 
      p 'params[:code]'
      token_info = FacebookAuth.get_access_token_info(params[:code])
      @user = User.add_facebook(token_info)
      redirect_to :action => 'show', :id => @user.id
    else
      p 'redirecting to fb'
      render :layout => false, :inline => "<html><head>\n<script type=\"text/javascript\">\nwindow.top.location.href = '<%=raw(@facebook_url) %>';\n</script>\n"
  #https://graph.facebook.com/oauth/authorize?client_id=163086873741036&redirect_uri=http://apps.facebook.com/friends_mapper/&scope=user_location,friends_location,publish_stream
    end
    
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
end
