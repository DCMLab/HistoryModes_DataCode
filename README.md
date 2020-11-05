# Data and Code for "Exploring the foundations of tonality: Statistical cognitive modeling of modes in the history of Western classical music"

This repository contains the data and code necessary to reproduce the results for our paper "Exploring the foundations of tonality: Statistical cognitive modeling of modes in the history of Western classical music", published in [*Humanities and Social Sciences Communications*](https://www.nature.com/palcomms/).

* Link to paper: *not available yet*
* Link to appendix: *not available yet*

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

All configuration files and all files that contain programming code are under GPLv3 license that is written in the file `LICENSE_GPL.txt`. This includes in particular files with a name extension of `.jl`, `.toml`, and `.ipynb`.

All other files are under CCv4 BY-NC-SA license that is written in the file `LICENSE_CC.md`. This includes in particular files with a name extension of `.csv`, `.txt`, and `.pdf`.

If you use any of the code or data from this repository in your own work, please provide a reference to our research paper as specified above.

## Funding statement

This project has received partial funding from the European Research Council (ERC) under the European Union's Horizon 2020 research and innovation program under grant agreement No 760081 – PMSB. It was also partially funded through the Swiss National Science Foundation within the project "Distant
Listening – The Development of Harmony over Three Centuries (1700–2000)". We thank Claude Latour for supporting this research through the Latour Chair in Digital Musicology. We want to express our gratefulness towards the owners of [ClassicalArchives](https://www.classicalarchives.com/), in particular Pierre R. Schwob, for making the data available for our research.
