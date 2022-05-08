drumpath = "../../../musicbox/SAMPLESWAP/DRUMS (FULL KITS)/DRUM MACHINES/808 Extended"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Sample selection and pad drawing (from sampleswap.org)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
drumpath = "./samples_test/"

ndrums = length(list.files(drumpath))

# Force into square matrix, pad with NA
if(sqrt(ndrums) > floor(sqrt(ndrums))) ndrums = ceiling(sqrt(ndrums)) ^ 2
drum = matrix(c(list.files(drumpath), rep(NA, ndrums-length(list.files(drumpath)))),
              floor(sqrt(ndrums)))
drum = gsub(".wav", "", drum)

init <- function() {
  grid.raster(matrix(rainbow(ndrums), floor(sqrt(ndrums))), interpolate = FALSE)
  box_names = as.data.frame(expand.grid(seq_len(floor(sqrt(ndrums))), 
                                        seq_len(floor(sqrt(ndrums)))))
  box_names$name = apply(box_names, 1, function(x) drum[x[1], x[2]])
  box_names$x = (box_names[,1])/max(box_names[,1]) 
  box_names$y = (box_names[,2])/max(box_names[,2])
  box_names$x = box_names$x - min(box_names$x)/2
  box_names$y = box_names$y - min(box_names$y)/2
  apply(box_names, 1, function(x) {
    grid.text(x[3], 
              x = unit(x[4], "npc"),  
              y = unit(x[5], "npc"), 
              gp = gpar(cex = 0.7))
  })
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Loop with controls
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Init a list of audioInstances for playback control

preload <- function() {
  drums = as.character(drum)
  drums = drums[!is.na(drums)]
  instances = lapply(drums, function(x) {
    curr = audio::load.wave(paste0(drumpath, "/", x, ".wav"))
    curr_i = audio::play(curr)
    audio::pause(curr_i)
    return(curr_i)
  })
  names(instances) = drums
  return(instances)
}

instances = preload()

# Define global variables to keep track of states
# Will redo in R6 

loop <- FALSE
current_drum <- NA
a = b = as.list(rep(0, length(instances)))
a_start = currp = as.list(rep(NA, length(instances)))
names(a) = names(a_start) = names(b) = names(currp) = names(instances) 
paused = FALSE
is_looped <- as.list(rep(FALSE, length(instances)))

# Main loop function

play <- function(event, mouse_x, mouse_y, fps_target = 30, ...) {
  
  # Keeps track of time by counting frames
  fs <- eventloop:::init_fps_governor()
  fs_current = eventloop:::fps_governor(fps = 30, fs)
  a <<- relist(unlist(a) + 1, a)
  b <<- relist(unlist(a)/fs_current, b)

  # Clicking to play
  if (!is.null(event)) {
    if (event$type == 'mouse_down') {
      x = ceiling(mouse_x * floor(sqrt(ndrums)))
      y = ceiling(mouse_y * floor(sqrt(ndrums)))
      
      if(is.na(drum[x,y])) return()
      
      current_drum <<- drum[x,y]
      
      a_start[[current_drum]] <<- b[[current_drum]]
      
     instance = instances[[current_drum]]$data
     currp[[current_drum]] <<-  audio::play(instance)
    
     if(loop) {
      is_looped[[current_drum]] <<- TRUE
     }
     
  } else if(event$type == "key_press") {
      
      # Playback controls: 
      # p: pause
      # w: rewind
      # r: resume
      # d: delete current list 
      # l: loop
      
      switch(event$st,
             "p" = {lapply(currp[!is.na(unlist(currp))], audio::pause); paused <<- TRUE; a_start <<- b; print("Pause")},
             "w" = {lapply(currp[!is.na(unlist(currp))], audio::rewind); b <<- a_start; print("Rewind")},
             "r" = {lapply(currp[!is.na(unlist(currp))], audio::resume); paused <<- FALSE; print("Resuming")},
             "d" = {lapply(currp[!is.na(unlist(currp))], audio::pause); currp <<- as.list(rep(NA, length(instances))); loop = FALSE; print("Deleted")},
             "l" = {if(loop) {
               loop <<- FALSE
               print("Loop OFF")
               } else {
               loop <<- TRUE
               print("Loop ON")}
               }) 
    } 
  }
  
 # Looping a specific sample: can loop samples separately
  
  if(loop) {
    if(length(currp) < 1 | is.na(current_drum)) return() else {
      if(!paused){
        drums_to_loop = names(is_looped[unlist(is_looped)])
          lapply(drums_to_loop, function(x) {
       timediff <<- b[[x]] - a_start[[x]]
       if(timediff >= length(currp[[x]]$data)/(44100 * 2)) {
         a_start[[x]] <<- b[[x]]
         currp[[x]] <<- audio::play(currp[[x]]$data)
       }
     })
      } else if(paused) return()
      }}
  }

# Play the thing
eventloop::run_loop(play, init_func = init, double_buffer = FALSE)
