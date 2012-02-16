# coding: utf-8
module TopicsHelper
  def format_topic_body(text, options = {})
    return '' if text.blank?

    convert_bbcode_img(text) unless options[:allow_image] == false

    result = MarkdownTopicConverter.convert(text)

    link_mention_floor(result)
    link_mention_user(result, options[:mentioned_user_logins]) unless options[:mentioned_user_logins].blank?
        
    return result.strip.html_safe
  end

  # convert bbcode-style image tag [img]url[/img] to markdown syntax ![alt](url)
  def convert_bbcode_img(text)
    text.gsub!(/\[img\](.+?)\[\/img\]/i) {"![#{image_alt $1}](#{$1})"}
  end

  # convert '#N楼' to link
  def link_mention_floor(text)
    text.gsub!(/#(\d+)([楼樓Ff])/) { link_to("##{$1}#{$2}", "#reply#{$1}", :class => "at_floor", "data-floor" => $1, :onclick => "return Topics.hightlightReply(#{$1})")}
  end

  # convert '@user' to link
  def link_mention_user(text, mentioned_user_logins)
    text.gsub!(/@(#{mentioned_user_logins.join('|')})/i) { link_to("@#{$1}", user_path($1), :class => "at_user", :title => "@#{$1}") }
  end

  def topic_use_readed_text(state)
    case state
    when true
      t("topics.have_no_new_reply")
    else
      t("topics.has_new_replies")
    end
  end

  def render_topic_title(topic)
    return t("topics.topic_was_deleted") if topic.blank?
    link_to(topic.title, topic_path(topic), :title => topic.title)
  end

  def render_topic_last_reply_time(topic)
    l((topic.replied_at || topic.created_at), :format => :short)
  end

  def render_topic_count(topic)
    topic.replies_count
  end

  def render_topic_created_at(topic)
    timeago(topic.created_at)
  end

  def render_topic_last_be_replied_time(topic)
    timeago(topic.replied_at)
  end
end
