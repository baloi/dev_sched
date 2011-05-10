# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def insurance_color resident
    #"yellow"
    if resident.insurance == "Med A" 
      return "FF3300" 
    elsif resident.insurance == "Med B"
      return "00CC66"
    elsif resident.insurance == "Medicaid"
      return "FF33FF"
    elsif resident.insurance == "HMO"
      return "#66CCFF"
    elsif resident.insurance == "RHMO"
      return "#66CCFF"
    elsif resident.insurance == "VA"
      return "#66CCFF"
    end
  end 

  def resident_insurace_select 
    a_tag = "<select id='resident_insurance' name='resident[insurance]'>"

    Resident.insurance_types.each do |insurance|
      selected = ''
      if insurance == @resident.insurance 
        selected = " selected='yes'"
      end
      a_tag += "<option value='#{insurance}'#{selected}>#{insurance}</option>"
    end

    a_tag += "</select>"
    a_tag
  end
end
