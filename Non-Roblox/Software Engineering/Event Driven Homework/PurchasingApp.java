package edu.unl.cse.soft161.event_driven;

import java.io.IOException;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Stage;

public class PurchasingApp extends Application {
	@Override
	public void start(Stage stage) throws IOException {
		Parent root = FXMLLoader.load(getClass().getResource("/edu/unl/cse/soft161/event_driven/PurchasingApp.fxml"));
		stage.setTitle("Purchasing App");
		stage.setScene(new Scene(root));
		stage.show();
	}

	public static void main(String... arguments) {
		Application.launch(PurchasingApp.class, arguments);
	}
}
