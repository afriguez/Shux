FROM elixir:1.14-alpine AS build

ENV MIX_ENV=prod

WORKDIR /app

COPY . /app/

RUN wget https://raw.githubusercontent.com/google/fonts/main/ofl/poppins/Poppins-Regular.ttf

RUN mix local.hex --force && \
	mix local.rebar --force && \
	mix deps.get && \
	mix compile && \
	mix release

FROM elixir:1.14-alpine

COPY --from=build /app/_build/prod/rel/shux /opt/shux
COPY --from=build /app/Poppins-Regular.ttf /usr/share/fonts/Poppins

CMD ["/opt/shux/bin/shux", "start"]
