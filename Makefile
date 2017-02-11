
export AWS_DEFAULT_PROFILE = spacebaby

all: publish

serve:
	jekyll serve

generate:
	jekyll build

publish: generate
	aws s3 sync _site/ s3://spaceba.by/ --acl public-read
