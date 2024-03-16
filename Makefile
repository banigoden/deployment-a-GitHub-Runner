.PHONY: init
init:
	poetry shell
	poetry install --no-root
	pre-commit install

.PHONY: clean
clean:
	rm -rf ./deployment/terraform/.terraform
	rm -rf ./deployment/terraform/*.hcl
	rm -rf ./deployment/terraform/*.tfstate

