# musicbox
Experiments with interactive audio loops in R

Playing with ideas and tools by [https://github.com/coolbutuseless](https://github.com/coolbutuseless).

These experiments in building a small sample sequencer make use of the `eventloop` and `audio` R packages. 

You can install `eventloop` as follows:

```
# install.package('remotes')
remotes::install_github('coolbutuseless/eventloop')
```
Also do take a look at the guides and examples on the [website](https://coolbutuseless.github.io/2022/05/06/introducing-eventloop-realtime-interactive-rendering-in-r/).

Installing `audio` from CRAN:

```
install.packages("audio")
```

## Notes
`audio` does not work with all types of .WAV files, so you have to choose the right bitrate/bit depth. The samples on [sampleswap][sampleswap.org] are ready to use, but you need to register to download, and to donate to have access to all samples. It may be possible to circumvent some of these limitations by performing conversion using `av`.

## Thanks to:
- mikefc for `eventloop` and ideas on drum machines 
- Simon Urbanek for the `audio` package
- CRAN and the R Core Team 

