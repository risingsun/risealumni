jQuery(document).ready(function() {
  jQuery('#mycarousel').jcarousel({
    size:jQuery("ul#mycarousel > li").length,
    vertical: true
  });
  appSlides();
  jQuery(function(){
    jQuery('#cropimage').Jcrop({
      onChange: showCoords,
      onSelect: showCoords,
      setSelect: [ 20, 130, 480, 230 ],
      addClass: 'custom',
      bgOpacity: .8,
      sideHandles: false
    });
  });
  jQuery('#cropBlurbImage').Jcrop({
    onSelect: showCoords,
    onChange: showCoords,
    setSelect: [ 20, 130,528,264],
    minSize:[528,264],
    aspectRatio: 4/2,
    allowMove: true,
    allowResize: true,
    allowSelect: false
  });
  
  jQuery("textarea.image_url").click(function(){
    this.select();
  });
});

function appSlides() {
  jQuery('div.image_cycle').cycle({
    fx:    'fade',
    speed: 5000
  });
}
function showCoords(c)
{
  jQuery( '#photo_x' ).val(c.x);
  jQuery( '#photo_y' ).val(c.y);
  jQuery( '#photo_width' ).val(c.w);
  jQuery( '#photo_height' ).val(c.h);
}
function gallery(){
  jQuery('div.navigation').css({
    'width' : '300px',
    'float' : 'left'
  });
  jQuery('div.content').css('display', 'block');
  jQuery('.content').galleriffic('#thumbs', {
    delay:                  2000,
    numThumbs:              12,
    preloadAhead:           0,
    enableTopPager:         true,
    enableBottomPager:      false,
    imageContainerSel:      '#slideshow',
    controlsContainerSel:   '#controls',
    loadingContainerSel:    '#loading',
    captionContainerSel:    '#caption',
    playLinkText:           'Play Slideshow',
    pauseLinkText:          'Pause Slideshow',
    prevLinkText:           '&lsaquo; Previous Photo',
    nextLinkText:           'Next Photo &rsaquo',
    onPageTransitionIn: function() {
      jQuery('#thumbs ul.thumbs').fadeIn('fast');
      jQuery('#thumbs ul.thumbs > li:visible').each(function(){
        if(jQuery(this).children("a:has('img')").length == 1){
        }else{
          jQuery(this).children('a').append("<img src = " + jQuery(this).attr('title') + "></img>");
          jQuery(this).removeAttr("title");
        }
      });
    },
    onPageTransitionOut:    function(callback) {
      jQuery('#thumbs ul.thumbs').fadeOut('slow', callback);
    }
  });
}

var SLIDE_SPEED = 500


function jeval(str){
  return eval('(' +  str + ');');
}



//tog
function tog(clicker, toggler, callback, speed){
  if (speed == undefined)
    speed = SLIDE_SPEED;
  if (callback)
    jQuery(clicker).click(function(){
      jQuery(toggler).slideToggle(speed, callback); return false;
    });
  else
    jQuery(clicker).click(function(){
      jQuery(toggler).slideToggle(speed); return false;
    });
}
function togger(j, callback, speed){
  if (speed == undefined)
    speed = SLIDE_SPEED;
  if(callback)
    jq(j).slideToggle(speed, callback); 
  else 
    jq(j).slideToggle(speed); 
}
//tog










//message
function async_message(m, d){
  message(m, d);
}
function messages(m, d){
  message(m, d);
}
function message(message, duration){
  if (duration == undefined){
    duration = 3000;
  }
  if (jq.browser.msie) { 
    jq("#message").css({
      position: 'absolute'
    });
  }
  jq("#message").text(message).fadeIn(1000);
  setTimeout('jq("#message").fadeOut(2000)',duration);
  return false;
}
//message


function debug(m){
  if (typeof console != 'undefined'){
    console.log(m);
  }
}
function puts(m){
  debug(m);
}


function thickbox(id, title, height, width){
  //    location.href = '/photos/' + id;
  //    return;
  if (height == undefined){ 
    height = 300
  }
  if (width == undefined){ 
    width = 300
  }
  tb_show(title, '#TB_inline?height='+ height +'&amp;width='+ width +'&amp;inlineId='+ id +'', false);
  return false;
}





function truncate(str, len){
  if (len == undefined){
    len = 9
  }
  
  if (str.length <= len+3){
    return str;
  }
  
  return str.substring(0, len) + '...'
}












function tog_login_element() {
  jq('.login_element, .checkout_element').toggle();
}



//start up
jq(function(){
  //waiter
  jQuery("#waiter").ajaxStart(function(){
    jq(this).show();
  }).ajaxStop(function(){
    jq(this).hide();
  }).ajaxError(function(){
    jq(this).hide();
  });
  
  jq('.jstruncate').truncate({
    max_length: 50
  });
  
  jq('#search_q').bind('focus.search_query_field', function(){
    if(jq(this).val()=='Search for Friends'){
      jq(this).val('');
    }
  });
  
  jq('#search_q').bind('blur.search_query_field', function(){
    if(jq(this).val()==''){
      jq(this).val('Search for Friends');
    }
  });
  
  jq('#search_all').bind('focus.search_query_field', function(){
    if(jq(this).val()=='Search'){
      jq(this).val('');
    }
  });
  
  jq('#search_all').bind('blur.search_query_field', function(){
    if(jq(this).val()==''){
      jq(this).val('Search');
    }
  });

  jq('#search_blog').bind('focus.search_query_field', function(){
    if(jq(this).val()=='Search Blogs'){
      jq(this).val('');
    }
  });
  
  jq('#search_blog').bind('blur.search_query_field', function(){
    if(jq(this).val()==''){
      jq(this).val('Search Blogs');
    }
  });
  
});
//start up






function toggleComments(comment_id)
{
  jq('#comment_'+comment_id+'_short, #comment_'+comment_id+'_complete').toggleClass('hidden');
  
  jq('#comment_'+comment_id+'_toggle_link').html(
    jq('#comment_'+comment_id+'_toggle_link').html() == "(more)" ? "(less)" : "(more)"
    );
}




Effect.SlideUpAndDown = function(element,tagid, head) {
  element = $(element);
  tagid = $(tagid);
  
  if(element.visible(element))
  {
    new Effect.SlideUp(element, {
      duration: 0.25
    });
    //$(tagid).removeClassName('active');
    $(head.id+"_img").src = replace($(head.id+"_img").src, 'hide', 'show')
      
      
  }
  else {
    new Effect.SlideDown(element, {
      duration: 0.25
    });
    //$(tagid).addClassName('active');
    $(head.id+"_img").src = replace($(head.id+"_img").src, 'show', 'hide')
  //lnk.childNodes[0].src = replace(lnk.childNodes[0].src, 'show', 'hide')
      
      
  }
    
}
  
function replace(s, t, u) {
  /*
   **    s  string to be processed
   **    t  string to be found and removed
   **    u  string to be inserted
   **  returns new String
   */
  i = s.indexOf(t);
  r = "";
  if (i == -1) return s;
  r += s.substring(0,i) + u;
  if ( i + t.length < s.length)
    r += replace(s.substring(i + t.length, s.length), t, u);
  return r;
}
  
  
  
//-------------------------------------------------------------------
// Trim functions
//   Returns string with whitespace trimmed
//-------------------------------------------------------------------
function LTrim(str){
  if (str == null) {
    return null;
  }
  for (var i = 0; str.charAt(i) == " "; i++)
  ;
  return str.substring(i, str.length);
}
  
function RTrim(str){
  if (str == null) {
    return null;
  }
  for (var i = str.length - 1; str.charAt(i) == " "; i--)
  ;
  return str.substring(0, i + 1);
}
  
function Trim(str){
  return LTrim(RTrim(str));
}
  
function LTrimAll(str){
  if (str == null) {
    return str;
  }
  for (var i = 0; str.charAt(i) == " " || str.charAt(i) == "\n" || str.charAt(i) == "\t"; i++)
  ;
  return str.substring(i, str.length);
}
  
function RTrimAll(str){
  if (str == null) {
    return str;
  }
  for (var i = str.length - 1; str.charAt(i) == " " || str.charAt(i) == "\n" || str.charAt(i) == "\t"; i--)
  ;
  return str.substring(0, i + 1);
}
  
function TrimAll(str){
  return LTrimAll(RTrimAll(str));
}
  
  
  
  
function checkEmail(){
  user_email = $('user_profile_attributes_email').value;
    
  if (Trim(user_email) == '') {
    $('email_msg').className = "error";
    $('email_msg').innerHTML = "Email cannot be blank";
    return false;
  }
  else
  if (!validateEmailFormat(user_email)) {
    $('email_msg').className = "error";
    $('email_msg').innerHTML = "Email is invalid";
    return false;
  }
      
  new Ajax.Request('/accounts/check_email', {
    asynchronous: true,
    evalScripts: true,
    method: 'get',
    parameters: 'email=' + user_email,
    onComplete: function(request){
    //$('progress_image_for_email').style.display = 'none';
    },
    onLoading: function(request){
    //$('progress_image_for_email').style.display = 'block';
    }
  });
      
}
    
function validateEmailFormat(email){
  var email_status = email.match(/([a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9._-]+)/gi);
      
  if (email_status) {
    return true;
  }
  else {
    return false;
  }
}
    
function checkLogin(){
  user_login = $('user_login').value;
      
  if (Trim(user_login) == '') {
    $('login_msg').className = "error";
    $('login_msg').innerHTML = "Login cannot be blank";
    return false;
  }
  else
        
    new Ajax.Request('/accounts/check_login', {
      asynchronous: true,
      evalScripts: true,
      method: 'get',
      parameters: 'login=' + user_login,
      onComplete: function(request){
      //$('progress_image_for_email').style.display = 'none';
      },
      onLoading: function(request){
      //$('progress_image_for_email').style.display = 'block';
      }
    });
      
}
    
function checkUncheckAll_Messages(elements,check_flag) {
  if(check_flag=="yes")
  {
    for(i=0;i<elements.length;i++)
    {
      if (elements[i].type=="checkbox")
        elements[i].checked=true;
    }
  }
          
  else
  {
    for(i=0;i<elements.length;i++)
    {
      if (elements[i].type=="checkbox")
        elements[i].checked=false;
    }
  }
}
            
function processingTime(name,ids)
{
  var a = ids;
  spi = 'spinner_' +  a.toString();
  link = name.toString() + a.toString();
  Element.hide(link);
  Element.show(spi);
              
}
function processingCompleted(name,ids)
{
  var a = ids;
  spi = 'spinner_' +  a.toString();
  link = name.toString() + a.toString();
  Element.hide(spi);
  Element.show(link);
             
             
}
function facebook_publish_feed_story(key,form_bundle_id,template_data,tag_id,body_general) {
  var user_message_prompt = "What's on your mind?";
  FB_RequireFeatures(["XFBML"], function()
  {
    FB.Facebook.init(key, "/xd_receiver.html");
    FB.Facebook.get_sessionState().waitUntilReady(function() {
      var user = FB.Facebook.apiClient.get_session() ?
      FB.Facebook.apiClient.get_session().uid :
      null;
      if (user && tag_id) {
        FB.ensureInit(function() {
          FB.Connect.showFeedDialog(form_bundle_id,template_data,[tag_id],body_general,null,user_message_prompt);
        });
      }
    })
  });
}
function facebook_publish_blog_story(key,form_bundle_id,template_data) {
  var user_message_prompt = "What's on your mind?";
  FB_RequireFeatures(["XFBML"], function()
  {
    FB.Facebook.init(key, "/xd_receiver.html");
    FB.Facebook.get_sessionState().waitUntilReady(function() {
      var user = FB.Facebook.apiClient.get_session() ?
      FB.Facebook.apiClient.get_session().uid :
      null;
      if (user) {
        FB.ensureInit(function() {
          FB.Connect.showFeedDialog(form_bundle_id,template_data,'','',null,user_message_prompt);
        });
      }
    })
  });
}
 



