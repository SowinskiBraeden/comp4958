# COMP 4958 Assignment 1 — Chat

## Run

From `assignments/01/chat`:

1. Start the supervised chat server:

   ```sh
   iex -S mix
   ```

2. Start the TCP proxy in that IEx session (default port `6666`):

   ```elixir
   Chat.Proxy.start()
   ```

   To use another port: `Chat.Proxy.start(7000)`.

3. In another terminal, compile and run a client:

   ```sh
   javac client/ChatClient.java
   java -cp client ChatClient
   ```

   Optional arguments are port, then host:

   ```sh
   java -cp client ChatClient 7000 localhost
   ```

4. Repeat step 3 in more terminals for additional users. Press Ctrl-D at the
   start of an input line to disconnect.

Run the automated checks with `mix test`.

## Commands

- `/N <nickname>` — set or change your nickname.
- `/L` — list current nicknames; works before registration.
- `/M <names> <message>` — message comma-separated nicknames/groups.
- `/G <Group> <names>` — create or replace a client-local named group.
- `/D <names>` — set the client-local default group.
- `/B <message>` — message the default group.

Commands are case-insensitive. Longer variants such as `/msg` and `/nickname`
are accepted because only the first two command characters are significant.
