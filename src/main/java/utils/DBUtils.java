package utils;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.TimeZone;

import javax.inject.Singleton;

import org.json.JSONArray;
import org.json.JSONObject;

@Singleton
public class DBUtils {

    private Connection connection;

    private synchronized Connection getConnection() {
        if (connection == null) {
            connection = createConnection();
            initializeViews();
        }
        try {
            return connection;
        } catch (Exception ex) {
            throw new RuntimeException("Failed to obtain a Connection from the data source: " + ex.getMessage(), ex);
        }
    }

    private synchronized Connection createConnection() {
        try {
            String timezone = TimeZone.getDefault().getID().toString();
            Connection connection = DriverManager.getConnection("jdbc:mysql://localhost/openpkw?serverTimezone=" + timezone + "&allowMultiQueries=true&useSSL=false", "openpkw", "lwejlr2k3jlsfedlk2j34");
            return connection;
        } catch (Exception ex) {
            throw new RuntimeException("Failed to create connection to the database: " + ex.getMessage(), ex);
        }
    }

    private void initializeViews() {
        try {
            System.out.println("Configuring views");
            String databaseInitializationFileName = "conf/init_database.sql";
            Path databaseInitializationFile = Paths.get(ClassLoader.getSystemResource(databaseInitializationFileName).toURI());
            String databaseInitializationScript = new String(Files.readAllBytes(databaseInitializationFile));
            getConnection().createStatement().execute(databaseInitializationScript);
            System.out.println("Views configuration complete");
        } catch (Exception ex) {
            throw new RuntimeException("Failed to initialize database views: " + ex.getMessage(), ex);
        }
    }

    public ResultSet executeQuery(String sqlQuery) {
        long startTime = System.currentTimeMillis();
        try {
            Statement stmt = getConnection().createStatement();
            ResultSet rs = stmt.executeQuery(sqlQuery);
            long endTime = System.currentTimeMillis();
            System.out.println(sqlQuery + " (" + (endTime - startTime + " ms)"));
            return rs;
        } catch (Exception ex) {
            throw new RuntimeException("Failed to execute query [" + sqlQuery + "]: " + ex.getMessage(), ex);
        }
    }

    public String executeQueryAndReturnJSON(String sqlQuery) {
        ResultSet rs = executeQuery(sqlQuery);
        return resultSet2json(rs);
    }

    private String resultSet2json(ResultSet rs) {
        try {
            int numColumns = rs.getMetaData().getColumnCount();
            JSONArray json = new JSONArray();
            while (rs.next()) {
                JSONObject obj = new JSONObject();

                for (int i = 1; i < numColumns + 1; i++) {
                    String column_name = rs.getMetaData().getColumnLabel(i);

                    switch (rs.getMetaData().getColumnType(i)) {
                    case java.sql.Types.ARRAY:
                        obj.put(column_name, rs.getArray(column_name));
                        break;
                    case java.sql.Types.BIGINT:
                        obj.put(column_name, rs.getInt(column_name));
                        break;
                    case java.sql.Types.BOOLEAN:
                        obj.put(column_name, rs.getBoolean(column_name));
                        break;
                    case java.sql.Types.BLOB:
                        obj.put(column_name, rs.getBlob(column_name));
                        break;
                    case java.sql.Types.DOUBLE:
                        obj.put(column_name, rs.getDouble(column_name));
                        break;
                    case java.sql.Types.FLOAT:
                        obj.put(column_name, rs.getFloat(column_name));
                        break;
                    case java.sql.Types.INTEGER:
                        obj.put(column_name, rs.getInt(column_name));
                        break;
                    case java.sql.Types.NVARCHAR:
                        obj.put(column_name, rs.getNString(column_name));
                        break;
                    case java.sql.Types.VARCHAR:
                        obj.put(column_name, rs.getString(column_name));
                        break;
                    case java.sql.Types.TINYINT:
                        obj.put(column_name, rs.getInt(column_name));
                        break;
                    case java.sql.Types.SMALLINT:
                        obj.put(column_name, rs.getInt(column_name));
                        break;
                    case java.sql.Types.DATE:
                        obj.put(column_name, rs.getDate(column_name));
                        break;
                    case java.sql.Types.TIMESTAMP:
                        obj.put(column_name, rs.getTimestamp(column_name));
                        break;
                    default:
                        obj.put(column_name, rs.getObject(column_name));
                        break;
                    }
                    if (rs.wasNull()) {
                        obj.put(column_name, JSONObject.NULL);
                    }
                }

                json.put(obj);
            }
            return json.toString(4);
        } catch (Exception ex) {
            throw new RuntimeException("Failed to convert ResultSet to JSON: " + ex.getMessage(), ex);
        }
    }
}