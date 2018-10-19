DSROOT=./Pods

# installation
install: bundle_install pod_install carthage_update
pod_install:
	bundle exec pod install
carthage_update:
	carthage update --platform iOS --cache-builds
bundle_install:
	bundle install --path=vendor/bundle --jobs 4 --retry 3

pod_deintegrate:
	bundle exec pod deintegrate

