FROM public.ecr.aws/lambda/python:3.10 AS PACKAGE

COPY requirements.txt ./
RUN python3.10 -m pip install -r requirements.txt -t .

FROM PACKAGE
# ソースはコンテナイメージの /var/task にコピーされる
COPY templates/* templates/
COPY *.py ./

# Command can be overwritten by providing a different command in the template directly.
CMD ["app.lambda_handler"]