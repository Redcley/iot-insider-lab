using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace IoTLab.AdDisplay.Helpers
{
	public class Messenger
	{
		private static readonly ConcurrentDictionary<MessengerKey, object> recipientDictionary = new ConcurrentDictionary<MessengerKey, object>();

		/// <summary>
		/// Gets the single instance of the Messenger.
		/// </summary>
		public static Messenger Default { get; } = new Messenger();

		/// <summary>
		/// Initializes a new instance of the Messenger class.
		/// </summary>
		private Messenger()
		{ }

		/// <summary>
		/// Static constructor needed for lazy thread safety.
		/// </summary>
		static Messenger()
		{ }

		/// <summary>
		/// Registers a recipient for a type of message T. The action parameter will be executed
		/// when a corresponding message is sent.
		/// </summary>
		/// <typeparam name="T"></typeparam>
		/// <param name="recipient"></param>
		/// <param name="action"></param>
		public async Task Register<T>(object recipient, Action<T> action)
		{
			await Register(recipient, action, null);
		}

		/// <summary>
		/// Registers a recipient for a type of message T and a matching context. The action parameter will be executed
		/// when a corresponding message is sent.
		/// </summary>
		/// <typeparam name="T"></typeparam>
		/// <param name="recipient"></param>
		/// <param name="action"></param>
		/// <param name="context"></param>
		public async Task Register<T>(object recipient, Action<T> action, object context)
		{
			await Task.Run(() =>
			{
				var key = new MessengerKey(recipient, context);
				recipientDictionary.TryAdd(key, action);
			});
		}

		/// <summary>
		/// Unregisters a messenger recipient completely. After this method is executed, the recipient will
		/// no longer receive any messages.
		/// </summary>
		/// <param name="recipient"></param>
		public async Task Unregister(object recipient)
		{
			await Unregister(recipient, null);
		}

		/// <summary>
		/// Unregisters a messenger recipient with a matching context completely. After this method is executed, the recipient will
		/// no longer receive any messages.
		/// </summary>
		/// <param name="recipient"></param>
		/// <param name="context"></param>
		public async Task Unregister(object recipient, object context)
		{
			await Task.Run(() =>
			{
				object action;
				var key = new MessengerKey(recipient, context);
				recipientDictionary.TryRemove(key, out action);
			});
		}

		/// <summary>
		/// Sends a message to registered recipients. The message will reach all recipients that are
		/// registered for this message type.
		/// </summary>
		/// <typeparam name="T"></typeparam>
		/// <param name="message"></param>
		public async Task Send<T>(T message)
		{
			await Send(message, null);
		}

		/// <summary>
		/// Sends a message to registered recipients. The message will reach all recipients that are
		/// registered for this message type and matching context.
		/// </summary>
		/// <typeparam name="T"></typeparam>
		/// <param name="message"></param>
		/// <param name="context"></param>
		public async Task Send<T>(T message, object context)
		{
			await Task.Run(() =>
			{
				IEnumerable<KeyValuePair<MessengerKey, object>> result;

				if (context == null)
				{
					// Get all recipients where the context is null.
					result = from r in recipientDictionary where r.Key.Context == null select r;
				}
				else
				{
					// Get all recipients where the context is matching.
					result = from r in recipientDictionary where r.Key.Context != null && r.Key.Context.Equals(context) select r;
				}

				foreach (var action in result.Select(x => x.Value).OfType<Action<T>>())
				{
					// Send the message to all recipients.
					action(message);
				}
			});
		}

		protected class MessengerKey
		{
			public object Recipient { get; }

			public object Context { get; }

			/// <summary>
			/// Initializes a new instance of the MessengerKey class.
			/// </summary>
			/// <param name="recipient"></param>
			/// <param name="context"></param>
			public MessengerKey(object recipient, object context)
			{
				Recipient = recipient;
				Context = context;
			}

			/// <summary>
			/// Determines whether the specified MessengerKey is equal to the current MessengerKey.
			/// </summary>
			/// <param name="other"></param>
			/// <returns></returns>
			protected bool Equals(MessengerKey other)
			{
				return Equals(Recipient, other.Recipient) && Equals(Context, other.Context);
			}

			/// <summary>
			/// Determines whether the specified MessengerKey is equal to the current MessengerKey.
			/// </summary>
			/// <param name="obj"></param>
			/// <returns></returns>
			public override bool Equals(object obj)
			{
				if (ReferenceEquals(null, obj)) return false;
				if (ReferenceEquals(this, obj)) return true;
				return obj.GetType() == GetType() && Equals((MessengerKey)obj);
			}

			/// <summary>
			/// Serves as a hash function for a particular type. 
			/// </summary>
			/// <returns></returns>
			public override int GetHashCode()
			{
				unchecked
				{
					return ((Recipient?.GetHashCode() ?? 0) * 397) ^ (Context?.GetHashCode() ?? 0);
				}
			}
		}
	}
}
