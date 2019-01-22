package com.eldor.playeraudio;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.DatabaseUtils;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import java.util.ArrayList;
import java.util.HashMap;

public class DBHelper extends SQLiteOpenHelper {

    public static final String DB_NAME = "song.db";
    public static final String TABLE_NAME = "music";
    public static final String COLUMN_ID = "id";
    public static final String COLUMN_URL = "url";
    private HashMap hp;

    public DBHelper(Context context){
        super(context,DB_NAME, null, 1);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        db.execSQL("create table " + TABLE_NAME +
        " (id integer primary key, url text)");
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int i, int i1) {
        db.execSQL("DROP TABLE IF EXISTS music");
        onCreate(db);
    }

    public boolean insertData(String url){
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues contentValues = new ContentValues();
        contentValues.put("url", url);
        db.insertWithOnConflict(TABLE_NAME, null, contentValues, SQLiteDatabase.CONFLICT_REPLACE);
        return true;
    }

    public Cursor getData(int id){
        SQLiteDatabase db = this.getReadableDatabase();
        Cursor res = db.rawQuery("select * from music where id=" + id +"", null);
        return res;
    }

    public int numberOfRows() {
        SQLiteDatabase db = this.getReadableDatabase();
        int number = (int) DatabaseUtils.queryNumEntries(db, TABLE_NAME);
        return number;
    }

    public boolean updateContact(Integer id, String url){
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues contentValues = new ContentValues();
        contentValues.put("url", url);
        db.update(TABLE_NAME, contentValues, "id= ? ", new String[]{Integer.toString(id)});
        return true;
    }

    public void deleteContact(Integer id){
        SQLiteDatabase db = this.getWritableDatabase();
        db.delete(TABLE_NAME, "id= ? ", new String[]{Integer.toString(id)});
    }

    public ArrayList<String> getAllContacts(){
        ArrayList<String> arrayList = new ArrayList<>();
        SQLiteDatabase db = this.getReadableDatabase();
        Cursor res = db.rawQuery("select * from "+TABLE_NAME, null);
        res.moveToFirst();

        while (!res.isAfterLast()){
            arrayList.add(res.getString(res.getColumnIndex(COLUMN_URL)));
            res.moveToNext();
        }
        return arrayList;
    }
}
