/*
 * Copyright (C) 2017 Katarina Sheremet
 * This file is part of Delern.
 *
 * Delern is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * Delern is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with  Delern.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.dasfoo.delern;

import android.support.test.rule.ActivityTestRule;
import android.support.test.runner.AndroidJUnit4;
import android.text.InputType;

import org.dasfoo.delern.listdecks.DelernMainActivity;
import org.dasfoo.delern.test.FirebaseOperationInProgressRule;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

import static android.support.test.espresso.Espresso.onView;
import static android.support.test.espresso.Espresso.pressBack;
import static android.support.test.espresso.action.ViewActions.click;
import static android.support.test.espresso.action.ViewActions.closeSoftKeyboard;
import static android.support.test.espresso.action.ViewActions.replaceText;
import static android.support.test.espresso.action.ViewActions.typeText;
import static android.support.test.espresso.action.ViewActions.typeTextIntoFocusedView;
import static android.support.test.espresso.assertion.ViewAssertions.matches;
import static android.support.test.espresso.matcher.ViewMatchers.hasSibling;
import static android.support.test.espresso.matcher.ViewMatchers.isDisplayed;
import static android.support.test.espresso.matcher.ViewMatchers.withId;
import static android.support.test.espresso.matcher.ViewMatchers.withInputType;
import static android.support.test.espresso.matcher.ViewMatchers.withText;
import static org.dasfoo.delern.test.WaitView.waitView;
import static org.hamcrest.Matchers.not;
import static org.hamcrest.core.AllOf.allOf;

@RunWith(AndroidJUnit4.class)
public class DeckOperationsTest {

    @Rule
    public ActivityTestRule<DelernMainActivity> mActivityRule = new ActivityTestRule<>(
            DelernMainActivity.class);

    @Rule
    public FirebaseOperationInProgressRule mFirebaseRule = new FirebaseOperationInProgressRule();

    @Test
    public void noDecksMessageShown() {
        waitView(withId(R.id.fab)).check(matches(isDisplayed()));
        waitView(allOf(withId(R.id.empty_recyclerview_message),
                withText(R.string.empty_decks_message))).check(matches(isDisplayed()));
    }
    @Test
    public void addEmptyDeckAndDelete() {
        waitView(withId(R.id.fab)).perform(click());
        onView(withInputType(InputType.TYPE_CLASS_TEXT))
                .perform(typeTextIntoFocusedView("Empty"), closeSoftKeyboard());
        onView(withText(R.string.add)).perform(click());
        onView(withId(R.id.add_card_to_db)).check(matches(isDisplayed()))
                .perform(closeSoftKeyboard());
        pressBack();
        waitView(withId(R.id.fab)).check(matches(isDisplayed()));
        // Check that deck was created with 0 cards
        waitView(withText("Empty")).check(matches(hasSibling(withText("0"))));
        onView(withId(R.id.empty_recyclerview_message)).check(matches(not(isDisplayed())));
        deleteDeck("Empty");
    }

    @Test
    public void createDeckWithCardToLearnAndDelete() {
        waitView(withId(R.id.fab)).perform(click());
        onView(withInputType(InputType.TYPE_CLASS_TEXT))
                .perform(typeTextIntoFocusedView("Learn"), closeSoftKeyboard());
        onView(withText(R.string.add)).perform(click());
        waitView(withId(R.id.add_card_to_db)).check(matches(isDisplayed()));
        onView(withId(R.id.front_side_text)).perform(typeText("front"));
        onView(withId(R.id.back_side_text)).perform(typeText("back"), closeSoftKeyboard());
        onView(withId(R.id.add_card_to_db)).perform(click());
        pressBack();
        // Start Learning Activity
        waitView(allOf(withText("Learn"), hasSibling(withText("1"))))
                .perform(click());
        // Check that front side is correct
        waitView(withId(R.id.textFrontCardView)).check(matches(withText("front")));
        // Flip card
        onView(withId(R.id.turn_card_button)).perform(click());
        // Check back side of card
        onView(withId(R.id.textBackCardView)).check(matches(withText("back")));
        pressBack();
        deleteDeck("Learn");
    }

    @Test
    public void createDeckToRenameAndDelete() {
        waitView(withId(R.id.fab)).perform(click());
        onView(withInputType(InputType.TYPE_CLASS_TEXT))
                .perform(typeTextIntoFocusedView("Created"), closeSoftKeyboard());
        onView(withText(R.string.add)).perform(click());
        waitView(withId(R.id.add_card_to_db))
                .check(matches(isDisplayed()))
                .perform(closeSoftKeyboard());
        pressBack();
        waitView(withId(R.id.fab)).check(matches(isDisplayed()));
        waitView(allOf(withId(R.id.deck_popup_menu), hasSibling(withText("Created"))))
                .perform(click());
        onView(withText(R.string.rename)).perform(click());
        onView(withInputType(InputType.TYPE_CLASS_TEXT))
                .perform(replaceText("Renamed"), closeSoftKeyboard());
        onView(withText(R.string.rename)).perform(click());
        waitView(withText("Renamed")).check(matches(hasSibling(withText("0"))));
        deleteDeck("Renamed");
    }

    private static void deleteDeck(final String deckName) {
        waitView(allOf(withId(R.id.deck_popup_menu), hasSibling(withText(deckName))))
                .perform(click());
        onView(withText(R.string.delete)).perform(click());
        onView(withText(R.string.delete)).perform(click());
    }
}