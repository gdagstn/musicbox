library(audio)
library(eventloop)

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Sample selection and pad drawing (from sampleswap.org)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
drumpath = "../../../musicbox/SAMPLESWAP/Canton's December 2019 Techno Special/Techno Special Basslines"

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
currp <- list()

play <- function(event, mouse_x, mouse_y, ...) {
  if (!is.null(event)) {
    if (event$type == 'mouse_down') {
      x = ceiling(mouse_x * floor(sqrt(ndrums)))
      y = ceiling(mouse_y * floor(sqrt(ndrums)))
      if(is.na(drum[x,y])) return()
      curr = audio::load.wave(paste0(drumpath, "/", drum[x,y], ".wav"))
      # appending to the list so all instances can be paused at once
      currp <<- c(currp, list(audio::play(curr)))
    }
# Playback controls: 
# p: pause
# w: rewind
# r: resume
# d: delete current list 
     if(event$type == "key_press") {
        switch(event$st,
          "p" = lapply(currp, audio::pause),
          "w" = lapply(currp, audio::rewind),
          "r" = lapply(currp, audio::resume),
          "d" = {lapply(currp, audio::pause); currp <<- list()})
       }
    }
}

eventloop::run_loop(play, init_func = init, double_buffer = FALSE)