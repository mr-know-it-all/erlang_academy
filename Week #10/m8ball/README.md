# m8ball (Distributed Magic 8-Ball Application)

A distributed Erlang/OTP application that provides random answers to questions. It demonstrates global process registration, dynamic failover, and takeover across a cluster of nodes.

## Architecture & Structure

* **Three-Module Design**: Consists of an application callback (`m8ball`), a supervisor (`m8ball_sup`), and a gen_server (`m8ball_server`).
* **Supervisor**: Uses a `one_for_one` strategy to keep the server process running permanently.
* **Global Registration**: The server registers globally (`{global, ?MODULE}`), letting any connected node call it transparently.

## Core Functionality

* **Config-Driven Answers**: Answers are stored as a tuple in the `.app` environment file for fast, constant-time lookups.
* **Crypto Seeding**: The server initializes its random number generator using 12 random bytes from the `crypto` module.
* **Question Ignoring**: The app completely ignores the text of the user's question to save processing and network overhead, instantly returning a random answer.

## Distributed Behavior (Failover & Takeover)

* **Split State**: The application runs on a cluster of three nodes (A, B, and C). It is "started" on all nodes but only active on one.
* **Failover**: Node A is the primary node. If Node A crashes, Node B automatically takes over and starts running the service.
* **Takeover**: When Node A comes back online, it automatically forces a takeover, gracefully shutting down the app on Node B to resume primary operations.

---

## Module Interaction Diagram

```text
[ Client Node ]          [ Any Node ]          [ Active Node ]
  Client Process          m8ball API            m8ball_server        m8ball_sup

        |                     |                       |                  |
        |--- ask(Question) -->|                       |                  |
        |                     |--- global:send/2 ---->|                  |
        |                     |    (Ignores Question) |                  |
        |                     |                       |-- lookup config  |
        |                     |                       |-- pick random    |
        |<--- Return Answer --|<--- Reply with Ans ---|                  |
        |                     |                       |                  |
        |                     |                       |                  |
        |                     |                       |  (If crashes)    |
        |                     |                       |X- - - - - - - - >|
        |                     |                       |  (Restarts)      |
        |                     |                       |<-- supervisor ---|
```

---

## Instructions to Run the Cluster

Follow these steps to compile the application and run it across three distributed nodes (`a`, `b`, and `c`) with failover enabled.

### 1. Compile the Code
Compile all Erlang source files in your project directory:
```elr
make:all([load, {outdir, "ebin"}]).
```

### 3. Start the Nodes
Open three separate terminal windows and launch each node. They will block until all three are online.

* **Terminal 1 (Node A - Primary):**
  ```bash
  erl -sname c -config config/a -pa ebin/
  ```
* **Terminal 2 (Node B - Backup 1):**
  ```bash
  erl -sname c -config config/b -pa ebin/
  ```
* **Terminal 3 (Node C - Backup 2):**
  ```bash
  erl -sname c -config config/c -pa ebin/
  ```

### 4. Start the Application
In **all three** terminal nodes, start the application:
```erlang
application:start(m8ball).
```
*Note: The application will only physically run its processes on Node A.*

### 5. Test the Application
From **any** of the three nodes, you can now call the API:
```erlang
m8ball:ask("Will this cluster stay up?").
```

### 6. Test Failover
Kill Node A (e.g., press `Ctrl+G` then `q` in Terminal 1). Run the command again on Node B or C:
```erlang
m8ball:ask("Did Node B take over?").
```
Node B will automatically take over and serve the answers.