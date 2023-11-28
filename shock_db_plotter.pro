PRO shock_db_plotter, best_fit=best_fit, xy=xy, circle_event=circle_event, high_low=high_low, subset=subset, delta_compress=delta_compress, delta_theta_BN=delta_theta_BN, delta_norm_theta=delta_norm_theta, delta_phi=delta_phi, Vm_new=Vm_new, std_Vm_new=std_Vm_new, Vs_new=Vs_new, error_Vs_new=error_Vs_new

; Main structure is 'shocks'
;
; shocks.E### = event ID number
;
; shocks.###.Shock_Type = type of shock event
; shocks.###.Notes = Notes on the shock event (managed by this database)
; shocks.###.V_multi = mutliple spacecraft MEAN shock speed
; shocks.###.V_multi_std = multiple spacecraft standard deviation
; shocks.###.V_single = single spacecraft shock velocity
; shocks.###.V_single_std = single spacecraft shock velocity stddev
; shocks.###.V_single_error = single spacecraft shock velocity error
; shocks.###.V_single_compress = single spacecraft compressability
; single.###.V_single_compress_error = single spacecraft compressability error
; shocks.###.V_single_theta_Bn = single spacecraft theta Bn
; shocks.###.V_single_theta_Bn_error = single spacecraft theta Bn error
; shocks.###.V_single_normtheta = single spacecraft normal vector theta
; shocks.###.V_single_normtheta_error = spacecraft normal vector theta error
; shocks.###.V_single_phi = single spacecraft normal vector phi
; shocks.###.V_single_phi_error = single spacecraft normal vector phi error

; KEYWORDS:
;
;       best_fit - display the best fit line in blue, toggle
;
;       xy - display the Y = X line in red, toggle
;
;       circle_event - set to the number event to be circled on the
;                      plot with the form circle_event = 796
;
;       high_low - display the upper and lower Y = X bounds, toggle
;
;       subset - plot only a subset of value provided as a list in the
;                form of [694, 721, 976] 
;
;       delta - plot the difference between single spacecraft and multi
;
;	Vm_new - Same as others, doesn't need to be set, is used by shock_scrapers

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Convert from structures to array for ease of plotting
shock_array = shock_db_to_array()

;Get parameters from file to plot
ID = shock_array.ID
Vm = shock_array.V_multi
Vm_std = shock_array.V_multi_std
Vs = shock_array.V_single
Vs_std = shock_array.V_single_std
Vs_error = shock_array.V_single_error
compress = shock_array.V_single_compress
compress_error =  shock_array.V_single_compress_error
theta_bn =  shock_array.V_single_theta_Bn
theta_bn_error = shock_array.V_single_theta_Bn_error
norm_theta = shock_array.V_single_normtheta
norm_theta_error = shock_array.V_single_normtheta_error
phi = shock_array.V_single_phi 
phi_error =  shock_array.V_single_phi_error

;For delta plotting analysis
delta = abs(Vm - Vs)

if keyword_set(subset) then begin
   ;Set up temporary storage arrays that will build the subset of data
   temp_ID = []
   temp_Vm = []
   temp_Vm_std = []
   temp_Vs = []
   temp_Vs_std = []
   temp_Vs_error = []
   ;Inform user of current events in database file
   print, 'The shock events in this file are:'
   print, ID
   wait, 0.5
   ;Set variables to build list from user input
   event_sub = ''
   events_subset = []
   ;Loop to have user add events until complete
   while (event_sub ne 'd') do begin
      ;grab user input of event number
       read, event_sub, PROMPT='Add datapoint to subset and type d when done: '
       ;add to running list
       if event_sub ne 'd' then events_subset = [events_subset, event_sub]
       ;Print current list to user so they know what they have added
       print, 'Current event subset: '
       print, events_subset
   endwhile
   ;Loop over each event in the subset and grab that data for that
   FOREACH event, events_subset do begin
      ; Get the index of the event being used
      event_index = where(ID eq event)
      if event_index eq -1 then begin
         print, 'Event '+string(event)+' not found in database. Going to next'
         wait, 0.25
         continue
      endif
      ;Grab the values for the correct event and add it to temp arrays
      temp_ID = [temp_ID, ID[event_index]] 
      temp_Vm = [temp_Vm, Vm[event_index]]
      temp_Vm_std = [temp_Vm_std, Vm_std[event_index]]
      temp_Vs = [temp_Vs, Vs[event_index]]
      temp_Vs_std = [temp_Vs_std, Vs_std[event_index]]
      temp_Vs_error = [temp_Vs_error, Vs_error[event_index]]
   endforeach
   ;Set the temporary arrays to be the main arrays for plotting
   ID = temp_ID
   Vm =temp_Vm
   Vm_std = temp_Vm_std
   Vs = temp_Vs
   Vs_std = temp_Vs_std
   Vs_error = temp_Vs_error
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Do a delta plot if keyword set
if keyword_set(delta_theta_bn) or keyword_set(delta_compress)  or keyword_set(delta_phi)  or keyword_set(delta_norm_theta) then begin
   ;Set values based on which keyword set
   ;compression
   if keyword_set(delta_compress) then xvalues = compress
   if keyword_set(delta_compress) then xerrors = compress_error
   ;theta_bn
   if keyword_set(delta_theta_BN) then xvalues = theta_bn
   if keyword_set(delta_theta_BN) then xerrors = theta_bn_error
   ;norm theta
   if keyword_set(delta_norm_theta) then xvalues = norm_theta
   if keyword_set(delta_norm_theta) then xerrors = norm_theta_error  
   ;phi
   if keyword_set(delta_phi) then xvalues = phi
   if keyword_set(delta_phi) then xerrors = phi_error
   ;Plot with a best fit line to compare abs(Vm-Vs) to the selected parameter
   line_x = findgen(max(xvalues)*1.2)
   delta_plot = scatterplot(xvalues,delta)
   result = linfit(xvalues, delta) ; measure_errors = xerrors
   intercept = result[0]
   slope = result[1]
   print, 'Intercept: '+string(intercept)
   print, 'Slope    : '+string(slope)
   ; Y = A_intercept + B_slope*x
   line_best_fit = intercept +slope*line_x 
   ;Plot the best fit line
   best_fit = plot(line_x, line_best_fit, /overplot, color='red', xrange=[min(xvalues)*0.8, max(xvalues)*1.2], yrange=[0,200])
   ;label best fit line
   myText = TEXT(0, 100, 'y ='+strcompress(intercept)+'+('+strcompress(slope)+')x', FONT_COLOR='red', $
   FONT_SIZE=9, FONT_STYLE='italic', /DATA, TARGET=myPlot)
   return
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;make the inital scatter plot
plot1 = scatterplot(Vm, Vs, symbol='circle', title ='Single Spacecraft vs. Multi-Spacecraft Shock Speed', xtitle='|V| Multi-spacecraft', ytitle='|V| Single-spacecraft', xrange=[0, 1000], yrange=[0,1000])

;plot the errors
y_error_plot = errorplot(Vm, Vs, Vm_std, Vs_error, /overplot, linestyle='none')

;Get important plotting values
; Max velocity
max_V = max(shock_array.V_multi)
;Array of integer X values from 0 to maximum value for plotting
line_x = findgen(1000)

;For shock scrapper pop up, add new datapoint
if keyword_set(Vm_new) then begin
   ;Get new point values
   Vm_new = [Vm_new]
   std_Vm_new = [std_Vm_new]
   Vs_new = [Vs_new]
   error_Vs_new = [error_Vs_new]
   ;Plot the new point in red
   new_plot_point = scatterplot(Vm_new, Vs_new, symbol='diamond', sym_color='red', sym_size=2, /overplot)
   ;plot the error of the new point
   new_error_plot = errorplot(Vm_new, Vs_new, std_Vm_new, error_Vs_new, /overplot, linestyle='none', sym_color='red')
   new_error_plot.sym_color='red'
endif

;Circle a particular point
if keyword_set(circle_event) then begin
   circle_event=circle_event
   print, 'Displaying event number: '+string(circle_event)
   circle_point_Vm = Vm[where(ID eq circle_event)]
   circle_point_Vs = Vs[where(ID eq circle_event)]
   circle_plot_point = scatterplot(circle_point_Vm, circle_point_Vs, symbol='circle',sym_size=5, /overplot)
endif

;Create a best fit line
if keyword_set(best_fit) then begin
   ;Get linear fit parameters using fitexy
   fitexy, Vm, Vs, intercept, slope, sigma_a_b, chi_sq, q, X_Sig = Vm_std, Y_sig=Vs_error
   ;Get sigma, chi_sq, and dofs
   sigma_intercept = sigma_a_b[0]
   sigma_slope =sigma_a_b[1]
   chi_sq = chi_sq
   degrees_of_freedom = n_elements(Vm) - 2
   ;Calculate the chi_sq / degrees of freedom
   fit_test = chi_sq/degrees_of_freedom
   ;Create useable strings for printing values
   intercept_string = string(intercept, FORMAT='(F5.2)')
   slope_string =string(slope, FORMAT='(F5.2)')
   sigma_int_string =string(sigma_intercept, FORMAT='(F5.2)')
   sigma_slope_string=string(sigma_slope, FORMAT='(F5.2)')
   fit_string = string(fit_test, FORMAT='(D7.2)')
   ;print values to terminal
   print, 'Intercept: '+intercept_string
   print, 'Slope    : '+slope_string
   ; Y = A_intercept + B_slope*x
   line_best_fit = intercept +slope*line_x 
   ;Plot the best fit line
   best_fit = plot(line_x, line_best_fit, /overplot, color='red', thick=3)
   ;label best fit line
   best_fit_label = TEXT(50, 900, 'y =('+strtrim(intercept_string)+' +/- '+strtrim(sigma_int_string)+') + ('+strtrim(slope_string)+' +/- '+strtrim(sigma_slope_string)+')x', FONT_COLOR='red', $
   FONT_SIZE=10, FONT_STYLE='italic', /DATA, TARGET=myPlot)
   ;label chi_sq value of line fit
   ;chi_Text = TEXT(50, 850, 'chi squared ='+strtrim(fit_string),FONT_COLOR='red', FONT_SIZE=10, FONT_STYLE='italic', /DATA, TARGET=myPlot)

endif

;plot the X = y line and some parameters above and below
if keyword_set(xy) then begin
   line_y = line_x
   xy_line = plot(line_x, line_y, /overplot, color='blue', linestyle='dashed', thick=3)
   ;label Y = X line
   myText = TEXT(900, 850, 'y = x', FONT_COLOR='blue', $
   FONT_SIZE=15, FONT_STYLE='italic', /DATA, TARGET=myPlot)
endif

;Add in dashed plus and minus regions (NEEDS BETTER HIGH AND LOW VALUES****)
if keyword_set(high_low) then begin
   line_y = line_x
   y_high= line_y+50
   y_low= line_y -50
   high_line = plot(line_x, y_high, /overplot, color='green', linestyle='dash')
   low_line = plot(line_x, y_low, /overplot, color='green', linestyle='dash')
endif

end
