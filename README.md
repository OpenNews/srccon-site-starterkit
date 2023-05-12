## SRCCON site starterkit

This repo has generic versions of the basic pages you need to create a new SRCCON site. By default, pages use the "simple" SRCCON template. [Check the demo site](http://site-starterkit.srccon.org) to see what's incuded and what it looks like.

This repository can be copied and pretty much be launched as-is—you can even just hit the "Use this template" button on the repository in GitHub—with just a few event-specific updates.

### What's in srccon-site-starterkit:
* directories
	* _config: The config files that Travis will use to push updates to the staging and production sites. These files should be good to go, no updates necessary.
	* _includes: Partial templates used for different pieces of SRCCON site pages
	* layouts: Primary templates for pages on the SRCCON site. The `layout.html` template includes header photos (e.g. https://2019.srccon.org). The `simple_layout.html` template does not have header photos (e.g. https://product.srccon.org).
	* media: Static CSS, JS, and img assets needed for the SRCCON site
* pages
	* homepage
	* code of conduct
	* scholarships
	* volunteers
	* sponsors (including an initial redirect that sends traffic to the "how to sponsor" page)

### Pre-launch checklist
What to do after copying this repository to set up a new SRCCON site:

* settings
	* CNAME
		* delete this file! (It only exists to point to [the demo site for this repo](http://site-starterkit.srccon.org).) If you use GitHub's "Create repository from template" feature to set up your new site repository, you may need to `git rm` this file to get rid of it.
	* _config.yml
		* `name`: Update this value to the new event name
		* `url`: Update this value to the new site URL
		* under `defaults`, add new values for:
			 * `event_name`
			 * `event_date`
			 * `event_place`
			 * `event_place_abbreviation`
		* under `defaults`, optionally change values for 
			* `description`: This is written for a midyear SRCCON. If the site is for a topical SRCCON, it should be changed accordingly.
			* `layout`: This is set to "simple_layout" for page designs that look like [the SRCCON:PRODUCT site](https://product.srccon.org). You can change the value to "layout_with_header_image" for a site with photo headers like [SRCCON 2019](https://2019.srccon.org). (This also may involve adding new images to the `media/img/backgrounds` directory, and updating various `#header-image` classes in `media/css/style.css`.)
			* `cta_button_link`: The "layout_with_header_image" design includes an orange "call to action" button. If the site is using this layout, set the button URL here.
			* `cta_button_text`: The "layout_with_header_image" design includes an orange "call to action" button. If the site is using this layout, set the button text here.
	* .travis.yml
		* update the value for `notifications.slack.rooms.secure`. The new value can be [generated from the command line](https://docs.travis-ci.com/user/notifications/#configuring-slack-notifications) using a token from your Travis CI integration on Slack. Before this will work, you'll need to set up the repository for the new SRCCON site on GitHub and make sure the project is being tracked by Travis.
* templates
	* _includes
		* in `simple_footer.html` (or `footer.html` if using `layout_with_header_image`), doublecheck the list of linked pages and the contact links for any updates. You'll also probably need to add a new item to the "Previous events" list.
		* in `simple_navigation.html` (or `navigation.html` if using `layout_with_header_image`), internal nav links are commented out by default. Doublecheck these in case you want to add any links to pages you're launching with.
	* homepage.md
		* in the "When & where" section, add information about the date, venue, and city. (There are lots of different ways we change up this text, so we don't automatically generate it from the config variables above.)
    * scholarships.md
        * this template assumes that scholarships include a $500 stipend. For some events, this value might need to be changed. Deadlines and dates are also helpful to add in sections like "How to apply" and "When notifications go out."
    * sponsors_about.md
        * this template contains example language describing the audience and program from SRCCON 2018. Those sections are commented out by default, but this can be updated to make the page more useful for potential sponsors.
    * sponsors.md
        * by default, this template is set up as an automatic redirect to the sponsors_about page. But if we already have sponsors in place when the site launches, this page can be updated to list them instead (and link to sponsors_about for more information).
* assets
	* media
		* img
			* `srccon_logo.png` is the primary SRCCON logo (the one that says "SRCCON" set at an angle). If you're creating a site for a topical SRCCON instead, you'll want to create appropriate logo files (generally 800px tall, probably starting from [this Illustrator template](https://github.com/OpenNews/media-assets/blob/master/srccon/srccon_thematic_logo_template.ai).)
			* `srccon_logo_share.png` is the version of the logo used by social-media share cards. If you create a new logo for an event, also make a 1200x600 version of it and replace this file.
