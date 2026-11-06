import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.Socket;

/**
 * A dumb terminal client for the chat system.
 *
 * The main thread forwards standard input to the proxy. A second thread reads
 * the socket continuously because chat messages may arrive at any time.
 */
public class ChatClient {
  private static final int DEFAULT_PORT = 6666;
  private static final String DEFAULT_HOST = "localhost";
  private static final String RED = "\u001B[31m";
  private static final String PURPLE = "\u001B[35m";
  private static final String RESET = "\u001B[0m";

  public static void main(final String[] args) {
	try {
	  var port = args.length >= 1 ? parsePort(args[0]) : DEFAULT_PORT;
	  var host = args.length >= 2 ? args[1] : DEFAULT_HOST;
	  run(host, port);
	} catch (IllegalArgumentException e) {
	  printError(e.getMessage());
	  printError("usage: java ChatClient [port [host]]");
	} catch (IOException e) {
	  printError("connection error: " + e.getMessage());
	}
  }

  private static void run(String host, int port) throws IOException {
	try (
	  var socket = new Socket(host, port);
	  var server =
		new BufferedReader(new InputStreamReader(socket.getInputStream()));
	  var proxy =
		new PrintWriter(new OutputStreamWriter(socket.getOutputStream()), true);
	  var stdin =
		new BufferedReader(new InputStreamReader(System.in))
	) {
	  // Replies and chat messages arrive independently of keyboard input.
	  var receiver = new Thread(() -> receiveMessages(server, socket));
	  receiver.setName("chat-receiver");
	  receiver.setDaemon(true);
	  receiver.start();

	  String line;
	  while ((line = stdin.readLine()) != null) {
		proxy.println(line);

		if (proxy.checkError()) {
		  break;
		}
	  }

	  // Closing the socket tells the proxy worker to remove this nickname.
	  socket.close();
	}
  }

  private static void receiveMessages(BufferedReader server, Socket socket) {
	try {
	  String line;
	  while ((line = server.readLine()) != null) {
		// Validation/protocol errors are red; other incoming notifications and
		// chat messages are purple. Colouring stays entirely in the dumb client.
		var colour = line.startsWith("error:") ? RED : PURPLE;
		System.out.println(colour + line + RESET);
	  }
	} catch (IOException e) {
	  // A read failure caused by normal keyboard EOF needs no error message.
	  if (!socket.isClosed()) {
		printError("connection error: " + e.getMessage());
	  }
	}
  }

  private static void printError(String message) {
	System.err.println(RED + message + RESET);
  }

  private static int parsePort(String value) {
	try {
	  var port = Integer.parseInt(value);
	  if (port < 1 || port > 65535) {
		throw new IllegalArgumentException("port must be between 1 and 65535");
	  }
	  return port;
	} catch (NumberFormatException e) {
	  throw new IllegalArgumentException("port must be an integer");
	}
  }
}
