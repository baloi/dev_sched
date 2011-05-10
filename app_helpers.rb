module DataUtils
  
  def DataUtils.get_conflicts(rehab_day)
    conflicts = []
    if rehab_day.conflicts.all.first != nil
      rehab_day.conflicts.each do |conflict|
        conflicts << conflict.description
      end
    end
    
    conflicts
  end

  def DataUtils.flush_conflicts(rehab_day)
    #puts ">>> conflict length = #{rehab_day.conflicts.length} <<<"

    # baloi start (a bug seen, calling rehab_day.conflicts.all.first or last sort of enables
    # rehab_day.conflicts to be seen in haml or even in DataMapper, a bug? delayed saving?

    rehab_day.conflicts.length
    if rehab_day.conflicts.all.first != nil
      #puts ">>> conflict 1, description = #{rehab_day.conflicts.all.first.description} <<<"
      rehab_day.conflicts.all.first.description
    end
    if rehab_day.conflicts.all.last != nil
     #puts ">>> conflict 2, description = #{rehab_day.conflicts.all.last.description} <<<"
      rehab_day.conflicts.all.last.description

      #rehab_day.conflicts.all.each do |c|
      #  c.description
      #end
    end
  end
end

module DataBank
  def DataBank.create_initial_therapists
    therapists = []

    t1 = Therapist.new
    t1.name = "Telli"
    therapists << t1

    t2 = Therapist.new
    t2.name = "Teph"
    therapists << t2

    t3 = Therapist.new
    t3.name = "Wanda"
    therapists << t3

    therapists.each do |therapist|
      therapist.save
    end

  end 

  def DataBank.create_initial_residents
    residents = []
    r1 = Resident.new
    r1.name = 'Cruz, Juan'
    r1.insurance = 'Med A'
    r1.pt_minutes_per_day = 60 
    r1.pt_days_per_week = 5 
    r1.ot_minutes_per_day = 45 
    r1.ot_days_per_week = 5 

    residents << r1

    r2 = Resident.new
    r2.name = 'Esposo, Maria'
    r2.insurance = 'Med A'
    r2.pt_minutes_per_day = 60 
    r2.pt_days_per_week = 5 
    r2.ot_minutes_per_day = 45 
    r2.ot_days_per_week = 5 
    residents << r2

    r3 = Resident.new
    r3.name = 'Hermosa, Chris'
    r3.insurance = 'Med A'
    r3.pt_minutes_per_day = 75 
    r3.pt_days_per_week = 5 
    r3.ot_minutes_per_day = 75 
    r3.ot_days_per_week = 5 
    residents << r3


    r4 = Resident.new
    r4.name = 'Duncan, Mac'
    r4.insurance = 'Med A'
    r4.pt_minutes_per_day = 75 
    r4.pt_days_per_week = 5 
    r4.ot_minutes_per_day = 75 
    r4.ot_days_per_week = 5 
    residents << r4

    r5 = Resident.new
    r5.name = 'Pascual, Pedro'
    r5.insurance = 'CDPHP'
    r5.pt_minutes_per_day = 60 
    r5.pt_days_per_week = 5 
    r5.pt_minutes_per_day = 60 
    r5.pt_days_per_week = 5 
    residents << r5

    r6 = Resident.new
    r6.name = 'Lopez, Pablo'
    r6.insurance = 'CDPHP'
    r6.pt_minutes_per_day = 60 
    r6.pt_days_per_week = 5 
    r6.pt_minutes_per_day = 60 
    r6.pt_days_per_week = 5 
    residents << r6

    r7 = Resident.new
    r7.name = 'Alonzo, Betty'
    r7.insurance = 'CDPHP'
    r7.pt_minutes_per_day = 60 
    r7.pt_days_per_week = 5 
    r7.pt_minutes_per_day = 60 
    r7.pt_days_per_week = 5 
    residents << r7

    r8 = Resident.new
    r8.name = 'Smith, Charles'
    r8.insurance = 'CDPHP'
    r8.pt_minutes_per_day = 60 
    r8.pt_days_per_week = 5 
    r8.pt_minutes_per_day = 60 
    r8.pt_days_per_week = 5 
    residents << r8

    r9 = Resident.new
    r9.name = 'Heinz, David'
    r9.insurance = 'CDPHP'
    r9.pt_minutes_per_day = 60 
    r9.pt_days_per_week = 5 
    r9.pt_minutes_per_day = 60 
    r9.pt_days_per_week = 5 
    residents << r9

    residents.each do |resident|
      resident.save
    end
  end
end
