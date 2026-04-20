#!/usr/bin/env python3

from __future__ import annotations

import argparse
import shutil
import sqlite3
import time
import uuid
from pathlib import Path


DEFAULT_CONTACTS = [
    {
        "first": "민수",
        "last": "김",
        "organization": "네이버",
        "department": "플랫폼",
        "job_title": "iOS 개발자",
        "note": "WhoCallMe 한국어 테스트 연락처",
        "phone": "010-1234-5678",
    },
    {
        "first": "서연",
        "last": "이",
        "organization": "카카오",
        "department": "디자인",
        "job_title": "프로덕트 디자이너",
        "note": "WhoCallMe 한국어 테스트 연락처",
        "phone": "010-2345-6789",
    },
    {
        "first": "지훈",
        "last": "박",
        "organization": "쿠팡",
        "department": "커머스",
        "job_title": "백엔드 엔지니어",
        "note": "WhoCallMe 한국어 테스트 연락처",
        "phone": "010-3456-7890",
    },
    {
        "first": "유진",
        "last": "최",
        "organization": "토스",
        "department": "성장",
        "job_title": "마케터",
        "note": "WhoCallMe 한국어 테스트 연락처",
        "phone": "010-4567-8901",
    },
    {
        "first": "하늘",
        "last": "정",
        "organization": "라인",
        "department": "AI",
        "job_title": "리서처",
        "note": "WhoCallMe 한국어 테스트 연락처",
        "phone": "010-5678-9012",
    },
]


def simulator_addressbook_dir(udid: str) -> Path:
    return Path.home() / "Library/Developer/CoreSimulator/Devices" / udid / "data/Library/AddressBook"


def copy_databases(source_dir: Path, output_dir: Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source_dir / "AddressBook.sqlitedb", output_dir / "AddressBook.sqlitedb")
    shutil.copy2(source_dir / "AddressBookImages.sqlitedb", output_dir / "AddressBookImages.sqlitedb")


def contact_exists(cursor: sqlite3.Cursor, contact: dict[str, str]) -> bool:
    cursor.execute(
        """
        SELECT 1
        FROM ABPerson person
        LEFT JOIN ABMultiValue multi ON multi.record_id = person.ROWID AND multi.property = 3
        WHERE person.First = ? AND person.Last = ? AND multi.value = ?
        LIMIT 1
        """,
        (contact["first"], contact["last"], contact["phone"]),
    )
    return cursor.fetchone() is not None


def insert_contacts(db_path: Path) -> None:
    connection = sqlite3.connect(db_path)
    connection.create_function("ab_generate_guid", 0, lambda: str(uuid.uuid4()).upper())
    connection.create_function("ab_update_value_from_trigger", 3, lambda value, _field, _rowid: value)
    cursor = connection.cursor()
    now = int(time.time())

    for contact in DEFAULT_CONTACTS:
        if contact_exists(cursor, contact):
            continue

        cursor.execute(
            """
            INSERT INTO ABPerson (
                First,
                Last,
                Organization,
                Department,
                JobTitle,
                Note,
                Kind,
                StoreID,
                PersonLink,
                guid,
                CreationDate,
                ModificationDate,
                FirstSort,
                LastSort,
                FirstSortSection,
                LastSortSection,
                FirstSortLanguageIndex,
                LastSortLanguageIndex
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                contact["first"],
                contact["last"],
                contact["organization"],
                contact["department"],
                contact["job_title"],
                contact["note"],
                0,
                0,
                -1,
                str(uuid.uuid4()).upper(),
                now,
                now,
                contact["first"],
                contact["last"],
                contact["last"],
                contact["last"],
                1,
                1,
            ),
        )
        record_id = cursor.lastrowid
        cursor.execute(
            "INSERT INTO ABMultiValue (record_id, property, identifier, label, value, guid) VALUES (?, 3, 0, 3, ?, ?)",
            (record_id, contact["phone"], str(uuid.uuid4()).upper()),
        )

    connection.commit()
    connection.close()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build a temp Contacts DB with Korean test contacts for WhoCallMe")
    parser.add_argument("--udid", required=True, help="Simulator UDID")
    parser.add_argument("--output", required=True, help="Output directory for copied contacts DB")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    source_dir = simulator_addressbook_dir(args.udid)
    output_dir = Path(args.output)

    copy_databases(source_dir, output_dir)
    insert_contacts(output_dir / "AddressBook.sqlitedb")

    print(f"Prepared Korean test contacts DB at: {output_dir}")
    print("Next step:")
    print(f"idb contacts update --udid {args.udid} {output_dir}")


if __name__ == "__main__":
    main()
