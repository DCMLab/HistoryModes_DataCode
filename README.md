# Data and Code for "Exploring the foundations of tonality: Statistical cognitive modeling of modes in the history of Western classical music"

This repository contains the data and code necessary to reproduce the results for our paper "Exploring the foundations of tonality: Statistical cognitive modeling of modes in the history of Western classical music", published in [*Humanities and Social Sciences Communications*](https://www.nature.com/palcomms/).

* Link to paper:
* Link to appendix:

## Files
### Data

* `pitch_class_distributions.csv` contains the year, the root and mode (if given in the metadata), and the relative frequencies of the pitch classes in the respective piece, weighted by duration
* `bayesian_predictions.csv` contains the historical period (`0` to `4` from Renaissance to Late-Romantic), the estimated root, and the mode prediction of our Bayesian mode classifier
* `templates.csv` contains the (average) pitch class profiles ("key profiles") from different sources as described in the paper

### Code

To reproduce our results and figures, first run the `python_notebook.ipnb` until you are asked to run the `julia_notebook.ipynb`.  After running the latter completely, return to the Python notebook execute the remaining cells.


## Authors
Daniel Harasim ([daniel.harasim@epfl.ch](mailto:daniel.harasim@epfl.ch)), Fabian C. Moss, Matthias Ramirez, and Martin Rohrmeier

## Citation
Harasim, D., Moss, F. C., Ramirez, M., & Rohrmeier, M. (2020). Exploring the foundations of tonality: Statistical cognitive modeling of modes in the history of Western classical music. *Humanities and Social Sciences Communications*.

**BibTex**

```
@article{Harasim2020,
	author = {
		Harasim, Daniel and 
		Moss, Fabian C. and 
		Ramirez, Matthias and 
		Rohrmeier, Martin
		},
	title = {
		Exploring the foundations of tonality: 
		Statistical cognitive modeling of modes 
		in the history of Western classical music
		},
	journal = {Humanities and Social Sciences Communications},
	volume = {},
	number = {}
	year = {2020},
	doi = {}
}
```

## License

To be added