# Roadmap

### Next releases
- [ ] Blueprint copy count / sort by copy count
- [ ] Extract data from dyson spheres
- [ ] Extract data from icarus + color search
- [ ] Improve color search
- [ ] RGPD
- [ ] Comment system
- [ ] Admin interface
- [ ] Site wide messaging system
- [ ] In-site idea box / bug report
- [ ] Moderators profiles

### Tech / Chore
- [ ] JS Base controller with getController () => this.application.getControllerForElementAndIdentifier(document.querySelector("[data-controller*='preview']"), "preview") or https://dev.to/leastbad/the-best-one-line-stimulus-power-move-2o90
- [ ] Migrate to ComponentView
- [ ] Prepare for i18n
- [ ] Redo filter system cleanly
- [ ] Refactor blueprints controllers
- [ ] Refactor form views
- [ ] Refactor show views (sidebar, etc...)
- [ ] Update uppy.js to 2.0
- [ ] New error styles for f.input too
- [ ] Use TS instead of JS
- [ ] Update to Rails 7.0 and update CSS / JS loader
- [ ] Setup a better cache to relieve the dynos

### Planned features (probably)
- [ ] Localisation chinese
- [ ] Factories blueprints editor
- [ ] Add power needed to factories
- [ ] Optimize bundle size

### Maybe one day
- [ ] Bring back blueprint 3D preview (or 2D)
- [ ] Add tests

## Done
- [x] Update help
- [x] Common filters ability to filter by type
- [x] Fix download as zip for new blueprints
- [x] Add filters and search to all blueprint related pages
- [x] Add new items
- [x] Update the game version on live
- [x] Update the bp limits on live
- [x] Icarus blueprints sharing
- [x] Dyson Spheres blueprints sharing
- [x] Remove multibuild mods from home page research
- [x] Collections for Dyson Spheres and Icarus
- [x] Handle password recovey emails
- [x] Optimize, add includes, check for n+1 queries...
- [x] Seo, sitemap...
- [x] Add preview in blueprint creation form
- [x] Clicking on a tag on the blueprints index will search for this tag
- [x] Setup staging pipeline
- [x] Move image hosting to S3
- [x] Move database to new host
- [x] Meta tags
- [x] Add a way to flag outdated blueprints and notify the users
- [x] Hide collections with no blueprints
- [x] Order collections by popularity
- [x] Add a favorites page
- [x] Fix wrong `<Select>` background color on windows
- [x] Add a reset button to homepage form
- [x] Improve search by mod version, should find all compatible versions
- [x] Remove blueprint name when parsing blueprint
- [x] Add a link to "my collections" page from the collection page
- [x] Fix rendering of blueprints 3 times in show page
- [x] Add smelters / assemblers recipes detail
- [x] Way to add tags with icons in a cleaner fashion
- [x] Add tag "Lettering" / "Conveyor Belt Art" / "Early-game" / "Mid-game" / "Late-game"
- [x] Blueprint preview loader
- [x] Add tabs for preview / description / render preview only when needed
- [x] Remove cloudinary and active storage entirely