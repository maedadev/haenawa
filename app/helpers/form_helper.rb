module FormHelper
  
  def material_check_box builder, labe_name, method, options = {}, checked_value = "1", unchecked_value = "0"
    ret = []
    ret << raw('<div class="checkbox">')
    ret << raw('  <label>')
    ret << (builder.check_box method, options, checked_value, unchecked_value)
    ret << raw('    <span class="checkbox-material"><span class="check"></span></span>')
    ret << raw("    #{labe_name}")
    ret << raw('  </label>')
    ret << raw('</div>')
    ret.join("\n").html_safe
  end
  
  def material_check_box_tag labe_name, name, value = "1", checked = false, options = {}
    ret = []
    ret << raw('<div class="checkbox">')
    ret << raw('  <label>')
    ret << (check_box_tag name, value, checked, options)
    ret << raw('    <span class="checkbox-material"><span class="check"></span></span>')
    ret << raw("    #{labe_name}")
    ret << raw('  </label>')
    ret << raw('</div>')
    ret.join("\n").html_safe
  end
  
end
