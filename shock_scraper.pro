PRO shock_scraper, fresh_start=fresh_start, delete=delete, show_plot=show_plot

; Main structure is 'shocks'
; shocks.ID = event ID number
; shocks.V_multi = mutliple spacecraft MEAN shock speed
; shocks.V_multi_std = multiple spacecraft standard deviation
; shocks.V_single = single spacecraft shock velocity
; shocks.V_single_std = single spacecraft shock velocity stddev
; shocks.V_single_error = single spacecraft shock velocity error
; shocks.V_single_compress = single spacecraft compressability
; single.V_single_compress_error = single spacecraft compressability error
; shocks.V_single_theta_Bn = single spacecraft theta Bn
; shocks.V_single_theta_Bn_error = single spacecraft theta Bn error
  
;NOTE: Requires remove function to run correctly in IDL, which is part
;of SSWIDL

; KEYWORDS:
;
;       fresh_start - start a new list fresh (must be set the first time
;               this is run)
;
;       delete - delete a particular event from the current file
;
;       show_plot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; set the keyword 'fresh_start' to begin new databse and overwrite old
if keyword_set(fresh_start) then begin
    shocks = create_struct('ID',[-9999] ,'V_multi', [-9999], 'V_multi_std', [-9999], 'V_single', [-9999], 'V_single_std', [-9999], 'V_single_error', [-9999], 'V_single_compress', [-9999], 'V_single_compress_error', [-9999], 'V_single_theta_Bn', [-9999], 'V_single_theta_Bn_error', [-9999] )
endif

;if not set, will add to the new database
if NOT keyword_set(fresh_start) then restore, 'shock_velocity_data.idl'

; Grab the variables from the saved combined arrays
temp_ID = shocks.ID
temp_Vm = shocks.V_multi
temp_Vm_std = shocks.V_multi_std
temp_Vs = shocks.V_single
temp_Vs_std = shocks.V_single_std
temp_Vs_error = shocks.V_single_error
temp_compress = shocks.V_single_compress
temp_compress_error = shocks.V_single_compress_error
temp_theta_Bn = shocks.V_single_theta_Bn
temp_theta_Bn_error = shocks.V_single_theta_Bn_error

;Restore the current list of shocks and print to user
print, 'The following shocks have already been added'
print, shocks.ID
print, ''
wait, 0.5

;prompt user for new ID number to add to the database
new_ID = ''
if keyword_set(delete) then begin
    read, new_ID, PROMPT='Enter shock ID to remove: '
    print, 'Removing shock event number: '+new_ID
    ;If deleting, open the file and remove the event
    bad_index = where(shocks.ID eq new_ID)
    ;Remove this index for each array
    remove, [bad_index], temp_ID
    remove, [bad_index], temp_Vm
    remove, [bad_index], temp_Vm_std
    remove, [bad_index], temp_Vs
    remove, [bad_index], temp_Vs_std
    remove, [bad_index], temp_Vs_error
    remove, [bad_index], temp_compress
    remove, [bad_index], temp_theta_Bn
    ;Create a new structure with the deleted array
    shocks = create_struct('ID',temp_ID ,'V_multi', temp_Vm, 'V_multi_std', temp_Vm_std, 'V_single', temp_Vs, 'V_single_std', temp_Vs_std, 'V_single_error', temp_Vs_error, 'V_single_compress', new_compress, 'V_single_compress_error', new_compress_error, 'V_single_theta_Bn',  new_theta_Bn, 'V_single_theta_Bn_error', new_theta_Bn_error)
    ;Save new version
    save, shocks, filename='shock_velocity_data.idl'  
    ;Exit the program after removing
    wait, 0.5
    print, 'DELTED event number: '+new_ID
    return

;if not deleting, prompt user for number to add
endif else begin
   read, new_ID, PROMPT='Enter new shock ID to add: '
   print, 'Working on adding event number: '+new_ID
   print, ''
endelse

;Build filename for single and multi-spacecraft
s_file = '/crater/projects/shockdb/shocks/shockdb/shockdb_wi.idl'

multi_file_path = '/home.ufs/sdavis/phase3/'
multi_file_name = new_ID+'shock.idl'
m_file = multi_file_path+multi_file_name

;serach for both single spacecraft event data and multi-spacecraft
single_file_test = file_test(s_file)
multi_file_test = file_test(m_file)

;Quit program if both files don't exist
if (single_file_test eq 0) then begin
   print, 'ERROR! Cannot locate single spacecraft data at '+s_file
   return
endif

if  (multi_file_test eq 0) then begin
   print, 'ERROR! Cannot locate multi spacecraft data at '+m_file  
   return
endif

;check if event ID is already recorded in the database
; If so, ask the user to overwrite or to quit and try again
if where(temp_ID eq new_ID) ne -1 then begin
   print, 'This shock ID already exists in this database...'
   wait, 0.5
   print, 'Would you like to overwrite this data or quit?'
   wait, 0.5
   overwrite = ''
   read, overwrite, PROMPT='Overwrite (o) or Quit (q)? : '
   if (overwrite eq 'q') then return
endif

;Restore single spacecraft file
print, 'Restoring multi-spacecraft file...'
wait, 0.25
restore, s_file
;Create holder list of all the catalog shocks
event_list = shockdb.events
;Convert the event number to integer and get indexed array of correct data
event_number = uint(New_ID)
event_data = event_list[event_number]

;Grab the correct single spacecraft data
new_Vs = event_data.RH08.shock_speed.avg
new_Vs_std =  event_data.RH08.shock_speed.dev
basic_Vs_error = event_data.RH08.shock_speed.err
chi_sq = event_data.RH08.CHISQMIN
dof = event_data.RH08.DOF
new_compress = event_data.RH08.compression.avg
basic_compress_error = event_data.RH08.compression.err
new_theta_Bn = event_data.RH08.theta_bn.avg
basic_theta_Bn_error = event_data.RH08.theta_bn.err

;Renormalized uncertainty
new_Vs_error = (basic_Vs_error*dof)/(chi_sq)
new_compress_error = (basic_compress_error*dof)/(chi_sq)
new_theta_Bn_error = (basic_theta_Bn_error*dof)/(chi_sq)

;find the new multi-spacecraft data points
print, 'Restoring multi-spacecraft file...'
wait, 0.25
restore, m_file
new_Vm = mean(state.plane.V)
new_Vm_std = stddev(state.plane.V)

;print out new data summary and prompt user if they would like to save
print, 'The following data will be added:'
wait, 0.25
print, 'Event number: '+string(new_ID)
print, 'Single Spacecraft average velocity  : '+string(new_Vs)
print, 'Single Spacecraft velocity stddev   : '+string(new_Vs_std)
print, 'Single Spacecraft renormalized error: '+string(new_Vs_error)
print, 'Multi Spacecraft average velocity   : '+string(new_Vm)
print, 'Multi Spacecraft velocity stddev    : '+string(new_Vm_std)
print, 'Compressability                     : '+string(new_compress)
print, 'Compressabilit error                : '+string(new_compress_error)
print, 'Theta Bn                            : '+string(new_theta_Bn)
print, 'Theta Bn error                      : '+string(new_theta_Bn_error)
print, ''
wait,0.5

;Pop up plot to show new value
if keyword_set(show_plot) then shock_plotter, Vm_new = new_Vm, std_Vm_new=new_Vm_std, Vs_new=new_Vs, error_Vs_new=new_Vs_error

;Prompt the user to save
print, 'Do you want to save these new values?'
wait, 0.5
saver = ''
read, saver, PROMPT='Save new data? Yes (y) or No (n)? : '
if (saver eq 'n') then return

;if starting fresh, then replace the -9999 value instead of adding
if keyword_set (fresh_start) then begin
   shocks = create_struct('ID',new_ID ,'V_multi', new_Vm, 'V_multi_std', new_vm_std, 'V_single', new_Vs, 'V_single_std', new_Vs_std, 'V_single_error', new_Vs_error, 'V_single_compress', new_compress, 'V_single_compress_error', new_compress_error, 'V_single_theta_Bn',  new_theta_Bn, 'V_single_theta_Bn_error', new_theta_Bn_error)

; If adding to the arrays instead of starting fresh...
endif else begin
   ;First, see if you are ovewriting data for an entry
   if N_elements(overwrite) NE 0 then begin
      print, 'Overwriting data'
      wait, 0.5
      ;find the index that will be overwritten
      id_index = where(temp_ID eq new_ID)
      
;assign the new data value here
      temp_Vm[id_index] = new_Vm
      temp_Vm_std[id_index] = new_Vm_std
      temp_Vs[id_index] = new_Vs
      temp_Vs_std[id_index]= new_Vs_std
      temp_Vs_std[id_index] = new_Vs_error
      temp_compress[id_index] = new_compress
      temp_theta_Bn[id_index] = new_theta_Bn
      temp_compress_error[id_index] = new_compress_error
      temp_theta_Bn_error[id_index] = new_theta_Bn_error
      
;rename new array to match format below
      add_ID = temp_ID
      add_Vm = temp_Vm
      add_Vm_std = temp_Vm_std
      add_Vs = temp_Vs
      add_Vs_std = temp_Vs_std
      add_Vs_error = temp_Vs_error
      add_compress = temp_compress
      add_theta_Bn = temp_theta_Bn
      add_compress_error = temp_compress_error
      add_theta_Bn_error = temp_theta_Bn_error
   endif else begin

;Add new event data to temporary arrays if not overwritting
      add_ID = [temp_ID,new_ID] 
      add_Vm = [temp_Vm, new_Vm]
      add_Vm_std = [temp_Vm_std, new_Vm_std]
      add_Vs = [temp_Vs, new_Vs]
      add_Vs_std = [temp_Vs_std, new_Vs_std]
      add_Vs_error = [temp_Vs_error, new_Vs_error]
      add_compress = [temp_compress, new_compress]
      add_theta_Bn = [temp_theta_Bn, new_theta_Bn]
      add_compress_error = [temp_compress_error, new_compress_error]
      add_theta_Bn_error = [temp_theta_Bn_error, new_theta_Bn_error]
   endelse

;Sort arrays based on ID number
   sort_index = sort(add_ID)
   sorted_ID = add_ID[sort_index]
   sorted_Vm = add_Vm[sort_index]
   sorted_Vm_std = add_Vm_std[sort_index]
   sorted_Vs = add_Vs[sort_index]
   sorted_Vs_std = add_Vs_std[sort_index]
   sorted_Vs_error = add_Vs_error[sort_index]
   sorted_compress = add_compress[sort_index]
   sorted_compress_error = add_compress_error[sort_index]
   sorted_theta_Bn = add_theta_Bn[sort_index]
   sorted_theta_Bn_error = add_theta_Bn_error[sort_index]

   ;Populate the new structure
   shocks = create_struct('ID',sorted_ID ,'V_multi', sorted_Vm, 'V_multi_std', sorted_Vm_std, 'V_single', sorted_Vs, 'V_single_std', sorted_Vs_std, 'V_single_error', sorted_Vs_error, 'V_single_compress', sorted_compress, 'V_single_compress_error', sorted_compress_error, 'V_single_theta_Bn', sorted_theta_Bn, 'V_single_theta_Bn_error', sorted_theta_Bn_error)
;End of creating new structure from scratch or adding new data
endelse

;save data file under shock_velocity_data.idl
wait, 0.75
print, ''
print, 'Saved new file to shock_velocity_data.idl'
save, shocks, filename='shock_velocity_data.idl'  
print, 'To view this file, run the following two lines of code:'
print, "    restore, 'shock_velocity_data.idl', /verbose"
print, '    help, shocks'
print, ''

end
