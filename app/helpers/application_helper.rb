module ApplicationHelper
  def bootstrap_class_for_flash(type)
    case type.to_sym
    when :notice then "alert-success"
    when :alert  then "alert-danger"
    when :error  then "alert-danger"
    else "alert-info"
    end
  end
end
